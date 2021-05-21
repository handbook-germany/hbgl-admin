# frozen_string_literal: true

# This module represents the entire offer state machine and should stay
# together
# rubocop:disable Metrics/ModuleLength
require ClaratBase::Engine.root.join('app', 'models', 'offer')

module Offer::StateMachine
  extend ActiveSupport::Concern

  included do
    include AASM
    aasm do
      ## States

      # Normal Workflow
      state :initialized, initial: true
      state :completed
      state :approval_process # indicates the beginning of the approval process
      state :approved
      # indicates the beginning of the checkup_process (after deactivation)
      state :checkup_process

      # # Special states object might enter before it is approved
      # when a completed offer can not be approved it is disapproved
      state :disapproved
      state :edit # editing-state after disapproved or (unintended) completed

      # Special states object might enter after it was approved
      state :paused # I.e. Seasonal offer is in off-season (set automatically)
      state :expired # Happens automatically after a pre-set amount of time
      state :internal_feedback # There was an issue (internal)
      state :external_feedback # There was an issue (external)
      state :organization_deactivated # An associated orga was deactivated
      state :under_construction # Website under construction
      state :seasonal_pending # seasonal offer is reviewed but out of TimeFrame
      state :website_unreachable # crawler could not reach website 2 in a row

      ## Transitions

      event :complete,
            before: :set_completed_information,
            after: :set_completed_by! do
        transitions from: :initialized, to: :completed
        transitions from: :checkup_process, to: :completed
        transitions from: :edit, to: :completed
      end

      event :start_approval_process,
            guards: %i[
              expiration_date_in_future? all_organizations_visible?
            ] do
        transitions from: :completed, to: :approval_process
      end

      event :approve,
            before: :set_approved_information,
            after: :set_approved_by!,
            guards: %i[
              expiration_date_in_future? all_organizations_visible?
            ] do
        transitions from: :approval_process, to: :seasonal_pending,
                    guard: :seasonal_offer_not_yet_to_be_approved?
        transitions from: :checkup_process, to: :seasonal_pending,
                    guard: :seasonal_offer_not_yet_to_be_approved?
        transitions from: :approval_process, to: :approved
        transitions from: :checkup_process, to: :approved
        transitions from: :organization_deactivated, to: :approved
      end

      event :disapprove do
        transitions from: :approval_process, to: :disapproved
      end

      event :return_to_editing do
        transitions from: :disapproved, to: :edit
        transitions from: :completed, to: :edit
      end

      event :expire do
        transitions from: :approved, to: :expired
      end

      event :deactivate_internal do
        transitions from: :approved, to: :internal_feedback
        transitions from: :expired, to: :internal_feedback
        transitions from: :external_feedback, to: :internal_feedback
        transitions from: :under_construction, to: :internal_feedback
      end

      event :deactivate_external do
        transitions from: :approved, to: :external_feedback
        transitions from: :expired, to: :external_feedback
        transitions from: :internal_feedback, to: :external_feedback
        transitions from: :under_construction, to: :external_feedback
      end

      event :deactivate_through_organization do
        transitions from: :approved, to: :organization_deactivated,
                    guard: :at_least_one_organization_not_visible?
        transitions from: :expired, to: :organization_deactivated,
                    guard: :at_least_one_organization_not_visible?
      end

      event :website_under_construction do
        transitions from: :approved, to: :under_construction
        transitions from: :expired, to: :under_construction
        transitions from: :internal_feedback, to: :under_construction
        transitions from: :external_feedback, to: :under_construction
        transitions from: :organization_deactivated, to: :under_construction
        transitions from: :checkup_process, to: :under_construction
      end

      event :start_checkup_process do
        transitions from: :approved, to: :checkup_process
        transitions from: :paused, to: :checkup_process
        transitions from: :expired, to: :checkup_process
        transitions from: :internal_feedback, to: :checkup_process
        transitions from: :external_feedback, to: :checkup_process
        transitions from: :under_construction, to: :checkup_process
        transitions from: :website_unreachable, to: :checkup_process
        transitions from: :organization_deactivated, to: :checkup_process
      end
    end

    private

    def at_least_one_organization_not_visible?
      organizations.where.not(aasm_state: %w[approved all_done]).any?
    end

    def expiration_date_in_future?
      self.expires_at > Time.zone.now
    end

    def all_organizations_visible?
      organizations.visible_in_frontend.count == organizations.count
    end

    def set_approved_information
      self.approved_at = Time.zone.now
      # update to current LogicVersion
      self.logic_version_id = LogicVersion.last.id
    end

    def set_approved_by!
      self.update_columns approved_by: Creator::Twin.new(self).current_actor
    end

    def set_completed_information
      self.completed_at = Time.zone.now
      # update to current LogicVersion
      self.logic_version_id = LogicVersion.last.id
    end

    def set_completed_by!
      self.update_columns completed_by: Creator::Twin.new(self).current_actor
    end

    def seasonal_offer_not_yet_to_be_approved?
      !starts_at.nil? && starts_at > Time.zone.now
    end
  end
end
# rubocop:enable Metrics/ModuleLength
