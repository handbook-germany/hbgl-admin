# frozen_string_literal: true

module Offer::Contracts
  class Create < Reform::Form
    # fill me!
    property :name
    property :description
    property :comment
    property :encounter
    property :solution_category
    property :language_filters
    property :target_audience_filters_offers
    property :trait_filters
    property :area
    property :location
    property :aasm_state
    property :contact_people
    property :next_steps
    property :logic_version, writeable: false
    property :divisions
    property :starts_at
    property :ends_at
    property :tags
    property :openings
    property :opening_specification
    property :websites
    property :hide_contact_people
    property :code_word

    validates :name, presence: true
    # TODO: replace with complicated custom validation OR
    # save stamp text in model
    # validates :name,
    #           uniqueness: { scope: :location },
    #           unless: ->(offer) { offer.location.nil? }
    validates :description, presence: true
    validates :encounter, presence: true
    validates :solution_category, presence: true
    validates :code_word, length: { maximum: 140 }

    # Needs to be true before approval possible. Called in custom validation.
    # def before_approve
    #   TODO: Refactor age validations lead to simple HTML 5 checks which are
    #   eg not working in Safari. Also Rubocop complains...
    #   validate_associated_fields
    #   validate_target_audience
    # end
    validate :validate_associated_fields
    # validate :only_visible_organizations
    validate :location_and_area_fit_encounter
    validate :contact_people_are_choosable
    validate :no_more_than_10_next_steps
    validate :divisions_if_version_greater_7
    validate :divisions_must_have_same_sections

    # association getter
    def organizations
      divisions&.map { |d| d.organization }.flatten.uniq || []
    end

    private

    def validate_associated_fields
      validate_associated_presence :language_filters
    end

    def validate_associated_presence field
      custom_error field, "needs_#{field}" if send(field).empty?
    end

    ## Custom Validation Methods ##

    # Location is only allowed when encounter is personal, but if it is, it
    # HAS to be present. A remote offer needs an area.
    def location_and_area_fit_encounter
      if personal? && !location
        custom_error :location, 'needs_location_when_personal'
      elsif !personal?
        if location
          custom_error :location, 'refuses_location_when_remote'
        end
        unless area
          custom_error :area, 'needs_area_when_remote'
        end
      end
    end

    def custom_error attribute, string, optional = {}
      errors.add attribute, I18n.t(
        "offer.validations.#{string}"
      ), optional
    end

    # Contact people either belong to one of the Organizations or are SPoC
    def contact_people_are_choosable
      contact_people.each do |contact_person|
        next if contact_person.spoc ||
                organizations.include?(contact_person.organization)
        # There are no intersections between both sets of orgas and not SPoC
        custom_error :contact_people, 'contact_person_not_choosable'
      end
    end

    def no_more_than_10_next_steps
      return if next_steps.to_a.uniq.size <= 10
      custom_error :next_steps, 'no_more_than_10_next_steps'
    end

    def divisions_if_version_greater_7
      return if !logic_version || logic_version.version < 7 || !divisions.empty?
      errors.add :divisions, I18n.t('offer.validations.is_needed')
    end

    def divisions_must_have_same_sections
      return if divisions.empty? || divisions.pluck(:section_id).uniq.count < 2
      errors.add :divisions, I18n.t(
        'offer.validations.divisions_must_have_same_sections'
      )
    end

    def personal?
      encounter == 'personal'
    end

    # VISIBLE_FRONTEND_STATES = %w(approved expired).freeze
    #
    # def visible_in_frontend?
    #   VISIBLE_FRONTEND_STATES.include?(aasm_state)
    # end
  end

  class Update < Create
    property :id, virtual: true

    # fill me!
    validate :location_fits_organization
    validates :target_audience_filters_offers, presence: true
    # validate :validate_target_audience_filters_offers

    # Ensure selected organization is the same as the selected location's
    # organization
    def location_fits_organization
      ids = organizations.pluck(:id)
      if personal? && location && location.organization &&
         !ids.include?(location.organization.id)
        errors.add :location, I18n.t(
          'offer.validations.location_fits_organization'
        )
      end
    end

    #
    # def validate_target_audience_filters_offers
    #   unless target_audience_filters_offers.any?
    #     errors.add(
    #       :target_audience_filters_offers,
    #       I18n.t('offer.validations.needs_target_audience_filters')
    #     )
    #   end
    # end
  end

  class Approve < Update
    validates :next_steps, presence: true
  end
end
