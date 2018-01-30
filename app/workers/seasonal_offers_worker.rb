# frozen_string_literal: true

class SeasonalOffersWorker
  include Sidekiq::Worker

  def perform
    today = Time.zone.today

    # set expired seasonal offers from approved to seasonal_pending
    process_approved_offers_to_pending today

    # approve seasonal_pending offers if they entered their TimeFrame
    process_seasonal_pending_offers today
  end

  private

  # set approved seasonal offers to paused if they left their TimeFrame
  # no AsanaTask, no mailing, just pause the offers
  def process_approved_offers_to_pending today
    Offer.seasonal.where(aasm_state: 'approved')
         .where('ends_at <= ?', today).find_each do |offer|
      # set paused instead of expired and advance dates
      offer.update_columns aasm_state: 'seasonal_pending',
                           starts_at: offer.starts_at + 1.year,
                           ends_at: offer.ends_at + 1.year
      offer.index!
    end
  end

  # check seasonal_pending offers and force-approve them. No callbacks, so
  # the logic_version stays the same (might be outdated). Also approved_at and
  # approved_by don't get overwritten, which is good!
  def process_seasonal_pending_offers today
    Offer.where(aasm_state: 'seasonal_pending')
         .where('starts_at <= ?', today).find_each do |offer|
      offer.update_columns aasm_state: 'approved'
      offer.index!
    end
  end
end
