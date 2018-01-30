# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../support/utils/operation_test_utils'

# rubocop:disable Metrics/ClassLength
class OrganizationCreateTest < ActiveSupport::TestCase
  include OperationTestUtils

  it 'gets created with multiple submodels' do
    params = {
      data: {
        type: 'organizations',
        attributes: { name: 'foo' },
        relationships: {
          website: { data: { type: 'websites', id: '1' } },
          divisions: {
            data: [
              {
                type: 'divisions',
                attributes: { addition: 'bar' },
                relationships: {
                  section: { data: { type: 'sections', id: '1' } },
                  city: { data: { type: 'cities', id: '1' } }
                }
              }, {
                type: 'divisions',
                attributes: { addition: 'baz' },
                relationships: {
                  section: { data: { type: 'sections', id: '2' } },
                  city: { data: { type: 'cities', id: '1' } }
                }
              }
            ]
          },
          'contact-people': {
            data: [
              {
                type: 'contact-people',
                attributes: { 'first-name': 'jane' }
              }, {
                type: 'contact-people',
                attributes: { 'last-name': 'johnson' }
              }
            ]
          },
          'locations': {
            data: [
              {
                type: 'locations',
                attributes: {
                  name: 'HaQu', street: 'foob 1', zip: '12345',
                  'in-germany': true, hq: true
                },
                relationships: {
                  city: { data: { type: 'cities', id: '1' } },
                  'federal-state': { data: { type: 'federal-states', id: '1' } }
                }
              },
              { type: 'locations', id: '1' }
            ]
          }
        }
      }
    }

    result =
      api_operation_must_work API::V1::Organization::Create, params.to_json
    result['model'].name.must_equal 'foo'
    result['model'].created_by.must_equal 1
    result['model'].website_id.must_equal 1
    result['model'].divisions.length.must_equal 2
    result['model'].divisions.first.addition.must_equal 'bar'
    result['model'].divisions.first.section_id.must_equal 1
    result['model'].divisions.last.addition.must_equal 'baz'
    result['model'].divisions.last.section_id.must_equal 2
    result['model'].contact_people.length.must_equal 2
    result['model'].contact_people.first.first_name.must_equal 'jane'
    result['model'].contact_people.last.last_name.must_equal 'johnson'
    result['model'].locations.length.must_equal 2
    result['model'].locations.first.name.must_equal 'HaQu'
    result['model'].locations.first.city.name.must_equal 'Berlin'
    result['model'].locations.first.federal_state.id.must_equal 1
    result['model'].locations.last.street.must_equal 'basicStreet 1'
  end

  it 'wont get created with faulty website submodel' do
    params = {
      data: {
        type: 'organizations',
        attributes: { name: 'foo' },
        relationships: {
          website: { data: { type: 'websites', attributes: {
            host: 'not a valid host',
            url: 'not a valid url'
          } } }
        }
      }
    }

    result =
      api_operation_wont_work API::V1::Organization::Create, params.to_json
    result['contract.default'].errors.to_h.must_equal(
      website: { host: 'ist kein gültiger Wert', url: 'ist nicht gültig' }
    )
  end

  it 'wont get created with faulty division submodels' do
    params = {
      data: {
        type: 'organizations',
        attributes: { name: 'valid' },
        relationships: {
          website: { data: { type: 'websites', id: '1' } },
          divisions: {
            data: [
              {
                type: 'divisions', # no section and invalid website
                attributes: {},
                relationships: {
                  city: { data: { type: 'cities', id: '1' } },
                  websites: { data: [{
                    type: 'websites',
                    attributes: { host: 'own', url: 'invalid' }
                  }] }
                }
              }, {
                type: 'divisions',
                attributes: { addition: 'baz' } # no section
              }
            ]
          }
        }
      }
    }

    result =
      api_operation_wont_work API::V1::Organization::Create, params.to_json
    result['contract.default'].errors.to_h[:divisions].must_equal(
      0 => { websites: { 0 => { url: 'ist nicht gültig' } } },
      1 => {
        city: 'Stadt oder Area muss ausgewählt sein',
        area: 'Stadt oder Area muss ausgewählt sein'
      }
    )

    # fix one error, the deeper submodels are validated
    params[:data][:relationships][:divisions][:data].first[:relationships] =
      {
        section: { data: { type: 'sections', id: '1' } },
        city: { data: { type: 'cities', id: '1' } },
        websites: { data: [{
          type: 'websites',
          attributes: { host: 'own', url: 'invalid' }
        }] }
      }
    params[:data][:relationships][:divisions][:data].last[:relationships] =
      {
        section: { data: { type: 'sections', id: '2' } },
        city: { data: { type: 'cities', id: '1' } }
      }

    result =
      api_operation_wont_work API::V1::Organization::Create, params.to_json
    result['contract.default'].errors.to_h[:divisions].must_equal(
      0 => { websites: { 0 => { url: 'ist nicht gültig' } } }
    )
  end

  it 'must generate unique slugs' do
    params = {
      name: 'Best Orga Name Ever',
      website: { id: Website.first.id }
    }
    result = operation_must_work ::Organization::Create, params
    result['model'].slug.must_equal 'best-orga-name-ever'
  end
end
# rubocop:enable Metrics/ClassLength
