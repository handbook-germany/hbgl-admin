# frozen_string_literal: true

# Monkeypatch clarat_base Email
unless defined?(Email)
  require ClaratBase::Engine.root.join('app', 'models', 'email')
end

class Email < ApplicationRecord
  include ReformedValidationHack

  # Associations
  has_many :offer_mailings, inverse_of: :email
  has_many :known_offers, source: :offer, through: :offer_mailings,
                          inverse_of: :informed_emails

  # Search
  # include PgSearch
  # pg_search_scope :search_pg,
  #                 against: [:id, :address],
  #                 using: {
  #                   tsearch: { only: [:id], prefix: true },
  #                   trigram: { only: [:address], threshold: 0.3 }
  #                 }
  # NOTE Hack: use manual scope with LIKE query for containing search
  scope :search_pg, ->(input) {
    where('address LIKE ?', "%#{input}%").limit(30)
  }

  # NOTE: for later use
  # orga.first is okay because an orga-contact may
  # only belong to one organization
  # def newly_approved_offers_from_orga_context
  #   organizations.first.offers.visible_in_frontend
  #                .select(&:remote_or_belongs_to_informable_city?) -
  #     known_offers.all
  # end
end
