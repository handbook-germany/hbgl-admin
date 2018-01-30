# frozen_string_literal: true

require_relative '../test_helper'

describe Email do
  let(:email) { Email.new address: 'a@b.c' }
  subject { email }

  describe 'associations' do
    it { subject.must have_many :offer_mailings }
    it { subject.must have_many(:known_offers).through :offer_mailings }
  end

  describe 'methods' do
    # it 'should find all newly approved offers for an email' do
    #   email = FactoryGirl.create :email, :with_approved_and_unapproved_offer
    #   email.newly_approved_offers_from_offer_context.count.must_equal 1
    # end

    it 'should corretly use search_pg' do
      result = Email.search_pg('test')
      result.count.must_equal 1
    end
  end
end
