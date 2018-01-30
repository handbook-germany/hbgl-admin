# frozen_string_literal: true

require_relative '../test_helper'
# rubocop:disable Metrics/ClassLength
class GenericSortFilterTest < ActiveSupport::TestCase
  subject { GenericSortFilter }
  let(:query) { Offer.where('1 = 1') }
  let(:invalid_query) { OpenStruct.new }

  describe '#snake_case_contents' do
    it 'should transform kebab-case contents to snake_case' do
      params = {
        sort_field: 'foo-bar', sort_model: %w[offer-translation baz-fuz],
        sort_direction: 'ASC',
        filters: { 'offer-translation.foo-bar' => 'dont-touch' }
      }
      result = subject.send(:snake_case_contents, params)
      result.must_equal(
        sort_field: 'foo_bar', sort_model: %w[offer_translation baz_fuz],
        sort_direction: 'ASC',
        filters: { 'offer_translation.foo_bar' => 'dont-touch' }
      )
    end
  end

  describe '#transform_by_searching' do
    it 'does nothing without a param' do
      invalid_query.expects(:search_pg).never
      result = subject.send(:transform_by_searching, invalid_query, nil)
      result.must_equal invalid_query
    end

    it 'does nothing with an empty param' do
      invalid_query.expects(:search_pg).never
      result = subject.send(:transform_by_searching, invalid_query, '')
      result.must_equal invalid_query
    end

    it 'searches with a filled param for offer' do
      query.expects(:search_pg).with('foo').once
      subject.send(:transform_by_searching, query, 'foo')
    end

    # it 'searches with a filled param for orga' do
    #   orga_query = Organization.where('1 = 1')
    #   orga_query.expects(:with_pg_search_rank).once
    #   subject.send(:transform_by_searching, orga_query, 'orga')
    # end
  end

  describe '#transform_by_joining' do
    it 'eager_loads with a plain sort_model' do
      params = { sort_model: 'contact_people' }
      query.expects(:eager_load).with('contact_people')
      subject.send(:transform_by_joining, query, params)
    end

    it 'eager_loads with a nested sort_model' do
      params = { sort_model: 'contact_people.foo_bars' }
      query.expects(:eager_load).with('contact_people' => 'foo_bars')
      subject.send(:transform_by_joining, query, params)
    end

    it 'eager_loads with a filter' do
      params =
        { filters: { 'solution_category.foo' => 'a',
                     'logic_version.bar' => 'b' } }
      query.expects(:eager_load).with('solution_category').returns(query)
      query.expects(:eager_load).with('logic_version').returns(query)
      result = subject.send(:transform_by_joining, query, params)
      result.must_equal query
    end

    it 'wont eager_load without a sort_model or filter' do
      invalid_query.expects(:eager_load).never
      result = subject.send(:transform_by_joining, invalid_query, {})
      result.must_equal invalid_query
    end

    it 'wont eager_load with a filter that references itself' do
      params = { filters: ['offer.baz'] }
      query.expects(:eager_load).never
      subject.send(:transform_by_joining, query, params)
    end

    it 'wont eager_load with a filter that uses no submodel' do
      params = { filters: ['fuz'] }
      query.expects(:eager_load).never
      subject.send(:transform_by_joining, query, params)
    end
  end

  describe '#transform_by_ordering' do
    it 'will order with a sort_field but without sort_model (query model)' do
      params = { sort_field: 'foo' }
      query.expects(:order).with('offers.foo DESC')
      subject.send(:transform_by_ordering, query, params)
    end

    it 'will order respecting sort_field, sort_model, and sort_direction' do
      params =
        { sort_field: 'bar', sort_model: 'solution_category',
          sort_direction: 'ASC' }
      query.expects(:order).with('solution_categories.bar ASC')
      subject.send(:transform_by_ordering, query, params)
    end
  end

  describe '#model_for_filter' do
    it 'should classifiy and constantize for self-referring query' do
      subject.send(:model_for_filter, query, 'offer.name').must_equal Offer
    end
  end

  describe '#sort_range' do
    it 'should correctly sort date values' do
      values = [DateTime.current, DateTime.current - 1.day]
      subject.send(:sort_range, values).must_equal values.sort
    end

    it 'should correctly sort non date values via to_i' do
      values = [12, 8]
      subject.send(:sort_range, values).must_equal [8, 12]
    end
  end

  describe '#transform_by_filtering' do
    it 'wont transform without filters' do
      params = { filters: nil }
      invalid_query.expects(:where).never
      result = subject.send(:transform_by_filtering, invalid_query, params)
      result.must_equal invalid_query
    end

    it 'wont transform with an empty filter set' do
      params = { filters: {} }
      invalid_query.expects(:where).never
      result = subject.send(:transform_by_filtering, invalid_query, params)
      result.must_equal invalid_query
    end

    it 'wont transform with an empty filter value' do
      params = { filters: { foo: '' } }
      invalid_query.expects(:where).never
      result = subject.send(:transform_by_filtering, invalid_query, params)
      result.must_equal invalid_query
    end

    it 'filters for an owned field' do
      params = { filters: { 'foo' => 'bar' }, controller: 'api/controller' }
      query.expects(:where).with("controller.foo = 'bar'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters for an array of owned field with default OR-joining' do
      params = { filters: { 'foo' => %w[bar fuz] } }
      query.expects(:where).with("foo = 'bar' OR foo = 'fuz'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters for an array of owned field with !=-operator and AND-joining' do
      params = { filters: { 'x' => %w[bar fuz] }, operators: { 'x' => '!=' } }
      query.expects(:where)
           .with("x != 'bar' OR x IS NULL AND x != 'fuz' OR x IS NULL")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with a mismatching association/table name' do
      params = { filters: { 'language_filters.foobar' => 'bazfuz' } }
      query.expects(:where).with("filters.foobar = 'bazfuz'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with a 2-level deep association' do
      params = { filters: { 'section.cities.foobar' => 'bazfuz' } }
      query.expects(:where).with("cities.foobar = 'bazfuz'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with referring_to_own_table' do
      params = { filters: { 'offers.foobar' => 'bazfuz' } }
      query.expects(:where).with("offers.foobar = 'bazfuz'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with a nullable value' do
      params = { filters: { 'solution_category.baz' => 'nil' } }
      query.expects(:where).with('solution_categories.baz IS NULL')
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with a nullable value and NOT operator value' do
      params = { filters: { 'fuz' => 'NULL' }, operators: { 'fuz' => '!=' } }
      query.expects(:where).with('fuz IS NOT NULL')
      subject.send(:transform_by_filtering, query, params)
    end

    it 'includes NULL values for a "!=" string search' do
      params =
        { filters: { 'title' => 'smth' }, operators: { 'title' => '!=' } }
      query.expects(:where).with("title != 'smth' OR title IS NULL")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'performs case insensitive search with "ILIKE" operator' do
      params =
        { filters: { 'title' => 'Smth' }, operators: { 'title' => 'ILIKE' } }
      query.expects(:where).with("CAST(title AS TEXT) ILIKE '%Smth%'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'parses times and converts them correctly' do
      query = Opening.where('1 = 1')
      params = { filters: { 'open' => '13:00' } }
      query.expects(:where).with("open = '13:00'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'parses datetimes and converts them correctly' do
      value = '15.09.2014, 13:00'
      params = { filters: { 'created_at' => value } }
      query.expects(:where)
           .with("created_at = '#{Time.zone.parse(value).to_datetime}'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters and sorts a range when range consists of dates' do
      params = {
        filters: { 'foo' => { 'first' => '2017-08-15',
                              'second' => '2017-08-09' } },
        operators: { 'foo' => '...' }
      }
      query.expects(:where).with("foo BETWEEN '2017-08-09' AND '2017-08-15'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters and sorts a range when range consists of numbers' do
      params = {
        filters: { 'foo' => { 'first' => '5', 'second' => '1' } },
        operators: { 'foo' => '...' }
      }
      query.expects(:where).with("foo BETWEEN '1' AND '5'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters for a single value when no second value is given for range' do
      params = { filters: { 'foo' => '5' }, operators: { 'foo' => '...' } }
      query.expects(:where).with("foo = '5'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters for a single value when empty second'\
    ' value is given for range' do
      params = { filters: { 'foo' => ['5', ''] },
                 operators: { 'foo' => '...' } }
      query.expects(:where).with("foo = '5'")
      subject.send(:transform_by_filtering, query, params)
    end

    it 'filters with interconnecting OR operator' do
      params = {
        filters: { 'foo' => '1', 'fuz' => 'nil' },
        operators: { 'fuz' => '=', 'interconnect' => 'OR' }
      }
      query.expects(:where).with("foo = '1'").returns query
      query.expects(:or).with('fuz IS NULL')
      subject.send(:transform_by_filtering, query, params)
    end
  end
end
# rubocop:enable Metrics/ClassLength
