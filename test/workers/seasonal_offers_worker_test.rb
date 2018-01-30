# frozen_string_literal: true

require_relative '../test_helper'

class SeasonalOffersWorkerTest < ActiveSupport::TestCase # to have fixtures
  let(:worker) { SeasonalOffersWorker.new }

  it 'approves a seasonal_pending off that has entered its TimeFrame '\
     'and ignores another one out of its TimeFrame' do
    today = Time.zone.today
    starts_today = FactoryGirl.create :offer, aasm_state: 'seasonal_pending',
                                              starts_at: today,
                                              ends_at: today + 90.days
    starts_later = FactoryGirl.create :offer, aasm_state: 'seasonal_pending',
                                              starts_at: today + 30.days,
                                              ends_at: today + 90.days
    worker.perform
    starts_today.reload.must_be :approved?
    starts_later.reload.must_be :seasonal_pending?
  end

  # it 'it creates an AsanaTask for paused offers that start in 30 days '\
  #    'and does not change their states' do
  #   today = Time.zone.today
  #   starts_soon = FactoryGirl.create :offer, aasm_state: 'paused',
  #                                            starts_at: today + 30.days,
  #                                            ends_at: today + 90.days
  #   starts_later = FactoryGirl.create :offer, aasm_state: 'paused',
  #                                             starts_at: today + 60.days,
  #                                             ends_at: today + 90.days
  #   Offer.any_instance.expects(:index!).never
  #   AsanaCommunicator.any_instance.expects(
  #     :create_seasonal_offer_ready_for_checkup_task
  #   ).with(starts_soon)
  #   worker.perform
  #   starts_soon.reload.must_be :paused?
  #   starts_later.reload.must_be :paused?
  # end

  it 'it should set seasonal offers that left their TimeFrame to pending '\
     'but ignore non-seasonal offers' do
    today = Time.zone.today
    Timecop.freeze(today - 1.day)
    normal_offer = FactoryGirl.create :offer, aasm_state: 'approved',
                                              ends_at: today
    seasonal_offer = FactoryGirl.create :offer, aasm_state: 'approved',
                                                starts_at: today - 30.days,
                                                ends_at: today
    Timecop.return
    Offer.any_instance.expects(:index!).once
    worker.perform
    normal_offer.reload.must_be :approved?
    seasonal_offer.reload.must_be :seasonal_pending?
    seasonal_offer.reload.starts_at.must_equal(today - 30.days + 1.year)
    seasonal_offer.reload.ends_at.must_equal(today + 1.year)
  end
end
