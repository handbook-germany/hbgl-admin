# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../support/utils/operation_test_utils'

# rubocop:disable Metrics/ClassLength
class OfferUpdateTest < ActiveSupport::TestCase
  include OperationTestUtils

  let(:new_offer) { FactoryGirl.create(:offer) }

  it 'gets updated with a submodel' do
    params = {
      data: {
        type: 'offers',
        id: '1',
        attributes: { description: 'changed' },
        relationships: {
          'contact-people': {
            data: [{
              type: 'contact-people',
              attributes: { 'first-name': 'New', 'last-name': 'Guy' },
              relationships: {
                organization: { data: { type: 'organizations', id: '1' } }
              }
            }]
          }
        }
      }
    }

    result =
      api_operation_must_work API::V1::Offer::Update, params.to_json
    result['model'].description.must_equal 'changed'
    result['model'].contact_people.count.must_equal 1
    contact_person = result['model'].contact_people.last
    contact_person.label.must_equal("##{contact_person.id} New Guy (foobar) ")
  end

  describe 'translation side effect' do
    def update_description offer, description
      operation_must_work(
        ::Offer::Update, id: offer.id, description: description
      )
    end

    def change_state offer, event
      operation_must_work(
        ::Offer::Update, id: offer.id, 'meta' => { 'commit' => event.to_s }
      )
    end

    it 'should always get de translation, others on completion and change' do
      # Setup
      new_offer.translations.count.must_equal 1
      new_offer.translations.first.locale.must_equal 'de'
      new_offer.aasm_state.must_equal 'initialized'

      # First commit: only :de
      update_description new_offer, 'initial'
      new_offer.translations.count.must_equal 1 # only :de
      new_offer.translations.first.locale.must_equal 'de'

      # Changing things on an initialized offer doesn't change translations
      assert_nil new_offer.reload.description_ar
      update_description new_offer, 'change description wont update translation'
      new_offer.translations.count.must_equal 1
      assert_nil new_offer.reload.description_ar

      # Completion does not generate translations
      change_state new_offer, :complete
      new_offer.translations.count.must_equal 1

      # Approval generates all translations initially
      change_state new_offer, :start_approval_process
      change_state new_offer, :approve
      new_offer.reload.translations.count.must_equal I18n.available_locales.count

      # Now changes to the model change the corresponding translated fields
      EasyTranslate.translated_with 'CHANGED' do
        new_offer.description_ar.must_equal 'GET READY FOR CANADA'
        update_description new_offer, 'change description, updates translation'
        new_offer.reload.description_ar.must_equal 'CHANGED'
      end
    end

    it 'should update an existing translation only when the field changed' do
      # Setup
      update_description new_offer, 'New description'
      change_state new_offer, :complete
      new_offer.translations.reload.count.must_equal 1
      change_state new_offer, :start_approval_process
      change_state new_offer, :approve
      new_offer.translations.reload.count.must_equal I18n.available_locales.count
      new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'

      # Now changes to the model change the corresponding translated fields
      EasyTranslate.translated_with 'CHANGED' do
        new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'
        new_offer.description_ar.must_equal 'GET READY FOR CANADA'
        # changing untranslated field => translations must stay the same
        operation_must_work(
          ::Offer::Update, id: new_offer.id, comment: 'doesntMatter'
        )
        new_offer.reload.name_ar.must_equal 'GET READY FOR CANADA'
        new_offer.reload.description_ar.must_equal 'GET READY FOR CANADA'
        update_description new_offer, 'changing descr, should update translation'
        new_offer.reload.description_ar.must_equal 'CHANGED'
      end
    end

    it 'wont update changed fields for manually translated locales when the'\
       ' existing translation came from a human' do
      # Setup: Offer is first created
      change_state new_offer, :complete
      new_offer.translations.reload.count.must_equal 1
      change_state new_offer, :start_approval_process
      change_state new_offer, :approve
      new_offer.translations.reload.count.must_equal I18n.available_locales.count

      # Setup: A human edits the arabic translation and en
      ar_translation = new_offer.translations.find_by(locale: :ar)
      ar_translation.update_columns name: 'MANUAL EDIT', source: 'researcher'

      # Now changes to the model change the corresponding translated fields
      EasyTranslate.translated_with 'CHANGED' do
        new_offer.reload.name_ar.must_equal 'MANUAL EDIT'
        new_offer.description_ar.must_equal 'GET READY FOR CANADA'
        new_offer.name_ru.must_equal 'GET READY FOR CANADA'
        update_description(
          new_offer, 'changing descr, should update some translation'
        )
        new_offer.reload.description_ru.must_equal 'CHANGED'
        new_offer.reload.name_ar.must_equal 'MANUAL EDIT'
        new_offer.reload.description_ar.must_equal 'GET READY FOR CANADA'
        ar_translation.reload.possibly_outdated?.must_equal true
      end
    end
  end

  describe 'state change side-effects' do
    it 'wont approve if next_steps is empty' do
      # Setup
      new_offer.next_steps = []
      operation_wont_work(
        ::Offer::Update, id: new_offer.id, description: 'doesntMatter',
                         'meta' => { 'commit' => 'approve' }
      )
    end

    it 'wont change state without a correct meta commit action' do
      new_offer.aasm_state.must_equal 'initialized'
      assert_no_difference 'Statistic.count' do
        operation_must_work(
          ::Offer::Update, id: new_offer.id, description: 'doesntMatter',
                           'meta' => { 'commit' => 'doesntexist' }
        )
      end
      new_offer.reload.aasm_state.must_equal 'initialized'
    end

    it 'will abort all execution if the event is not allowed' do
      new_offer.aasm_state.must_equal 'initialized'
      Offer.any_instance.expects(:may_complete?).returns false
      assert_no_difference 'Statistic.count' do
        operation_wont_work(
          ::Offer::Update, id: new_offer.id, description: 'doesntMatter',
                           'meta' => { 'commit' => 'complete' }
        )
      end
      new_offer.reload.aasm_state.must_equal 'initialized'
    end

    it 'changes to complete state with the correct meta action' do
      new_offer.aasm_state.must_equal 'initialized'
      new_offer.valid?.must_equal true
      assert_no_difference 'Statistic.count' do
        operation_must_work(
          ::Offer::Update, id: new_offer.id, description: 'doesntMatter',
                           'meta' => { 'commit' => 'complete' }
        )
      end
      new_offer.reload.aasm_state.must_equal 'completed'
    end
  end
end
# rubocop:enable Metrics/ClassLength
