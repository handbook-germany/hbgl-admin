# frozen_string_literal: true

# Monkeypatch clarat_base Offer
require ClaratBase::Engine.root.join('app', 'models', 'offer')

class Offer < ApplicationRecord
  has_paper_trail

  EDITABLE_IN_STATES = %w[
    initialized approved expired checkup_process approval_process edit
  ].freeze

  # Modules
  include StateMachine
  include SearchAlgolia
  include ReformedValidationHack

  # Concerns
  include Translations

  # Callbacks
  after_initialize :after_initialize
  after_create :after_create
  before_create :before_create

  def after_initialize
    if self.new_record?
      self.logic_version_id = LogicVersion.last.id
    end
  end

  def after_create
    self.generate_translations!
  end

  def before_create
    return if self.created_by
    current_user = ::PaperTrail.whodunnit
    self.created_by = current_user if current_user.is_a? Integer # so unclean
  end

  # Search
  include PgSearch
  pg_search_scope :search_pg,
                  against: %i[
                    id name description aasm_state encounter
                    old_next_steps code_word
                  ],
                  # NOTE: this does not work with our filtered search queries
                  # associated_against: {
                  #   section: :name,
                  #   organizations: :name,
                  #   location: :label,
                  #   categories: :name_de,
                  #   solution_category: :name,
                  #   target_audience_filters: :name,
                  #   trait_filters: :name,
                  #   logic_version: :name
                  # },
                  using: { tsearch: { prefix: true } }

  # TODO? This works in console but raises ArgumentError otherwise...
  # pg_search_scope :search_dynamic, (lambda do |name_part, query|
  #   raise ArgumentError unless respond_to?(name_part)
  #   {
  #     against: name_part,
  #     query: query,
  #     using: { tsearch: { prefix: true } }
  #   }
  # end)

  # Associations
  has_many :offer_mailings, inverse_of: :offer
  has_many :informed_emails, source: :email, through: :offer_mailings,
                             inverse_of: :known_offers

  # Scopes
  scope :seasonal, -> { where.not(starts_at: nil, ends_at: nil) }

  # Getter Methods

  def expires_at
    (updated_at || created_at || Time.zone.today) + 1.year
  end

  # Admin specific methods
  delegate :identifier, to: :section, prefix: true

  # Customize duplication.
  # Lots of configs here, so we are OK with a longer method:
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def partial_dup
    self.dup.tap do |offer|
      offer.created_by = nil
      offer.location = self.location
      offer.divisions = self.divisions
      offer.openings = self.openings
      offer.section = self.section
      offer.language_filters = self.language_filters
      offer.trait_filters = self.trait_filters
      offer.websites = self.websites
      offer.contact_people = self.contact_people
      offer.tags = self.tags
      offer.next_steps = self.next_steps
      offer.area = self.area
      offer.aasm_state = 'initialized'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # we only want to inform the outside world about offers that are either remote
  # offers or belong to a city with a certain number of approved offers and
  # organizations
  def remote_or_belongs_to_informable_city?
    # search a city by area (remote offers that are limited to a certain area)
    city_by_area_name = area ? City.find_by(name: area.name) : nil
    direct_or_indirect_city = location ? location.city : city_by_area_name
    direct_or_indirect_city.nil? || direct_or_indirect_city.thresholds_reached?
  end

  def editable?
    EDITABLE_IN_STATES.include?(aasm_state)
  end

  def _residency_status_filters
    target_audience_filters_offers
      .order(:id).pluck(:residency_status).uniq.compact
  end
end
