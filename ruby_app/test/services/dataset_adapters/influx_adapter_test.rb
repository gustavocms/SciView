require_relative '../../test_helper'

describe DatasetAdapters::InfluxAdapter do
  specify { INFLUX_DB_NAME.must_equal "__sciview_test" }

  before do
    # Delete and recreate the database before every test.
    InfluxDB::Client.new.tap do |influx|
      influx.delete_database(INFLUX_DB_NAME) if influx.get_database_list.any? {|db| db["name"] == INFLUX_DB_NAME }
      influx.create_database(INFLUX_DB_NAME)
    end
  end

  let(:client){ InfluxDB::Client.new(INFLUX_DB_NAME) }
  let(:adapter){ DatasetAdapters::InfluxAdapter }

  describe :all do
    specify "empty list" do
      adapter.all.tap do |result|
        result.must_be_instance_of Array
        result.must_be_empty
      end
    end

    specify "with series" do
      client.write_point('test_series', { time: Time.now.to_i, value: 100 })
      adapter.all.tap do |result|
        result.wont_be_empty
        result[0]["key"].must_equal 'test_series'
      end
    end
  end

  describe :multiple_series do
    before do
      time = Time.new(2014, 1, 1).to_i
      [[(0...10), 'series_a'], [(100...110), 'series_b']].each do |range, name|
        range.each do |value|
          client.write_point(name, { time: time + value, value: value })
        end
      end
    end

    let(:start){ Time.new(2014, 1, 1) }
    let(:stop){ Time.new(2014, 1, 2) }
    let(:names){ %w[series_a series_b] }
    # sanity check
    specify { adapter.all.map {|series| series["key"] }.must_equal names }

    let(:to_hash){ adapter.multiple_series(start, stop, { series_1: 'series_a', series_2: 'series_b' }) }
    let(:a_values){ to_hash['series_a'][:values] }
    let(:b_values){ to_hash['series_b'][:values] }

    specify "returns a hash" do
      to_hash.tap do |result|
        result.keys.must_equal names
        a_values.must_be_instance_of Array
        a_values[0].tap do |value|
          value[:ts].must_equal start
          value[:value].must_equal 0
        end

        b_values[0].tap do |value|
          value[:ts].must_equal start + 100
          value[:value].must_equal 100
        end
        
        a_values.count.must_equal 10
        b_values.count.must_equal 10

      end
    end
  end

  let(:key){ 'default_series' }
  let(:add_default_series) { -> { (1..10).each {|n| client.write_point(key, { value: n, time: (Time.new(2014, 1, 1) + n).to_i })}}} 

  describe :tagging do
    before { add_default_series.call }
    specify :add_tag do
      adapter.add_tag(key, "TEST")
      adapter.series_metadata(key)['tags'].must_include "TEST"
    end

    specify :remove_tag do
      MetadataDelegate.find_or_initialize_by(:key => key).tap do |md|
        md.tags << "TEST"
      end.save

      adapter.series_metadata(key)['tags'].must_include "TEST"
      adapter.remove_tag(key, "TEST")
      adapter.series_metadata(key)['tags'].wont_include "TEST"
    end
  end

  describe :attributes do
    before { add_default_series.call }

    specify :update_attribute do
      adapter.update_attribute(key, "test_key", "test_value")
      adapter.series_metadata(key)['attributes'].must_equal({ "test_key" => "test_value" })
      adapter.update_attribute(key, "test_key", "test_value2")
      adapter.series_metadata(key)['attributes'].must_equal({ "test_key" => "test_value2" })
    end
  end

  describe :multiple_series_metadata do
    before do
      adapter.update_attribute('series_a', 'test_key', 'test_value_a')
      adapter.update_attribute('series_b', 'test_key', 'test_value_b')
      adapter.add_tag('series_b', "TAG B")
      adapter.add_tag('series_a', "TAG A")
    end

    specify do
      adapter.multiple_series_metadata({ a: 'series_a', b: 'series_b' }).tap do |result|
        result[0]['key'].must_equal 'series_a'
        result[0]['tags'].must_include 'TAG A'
        result[0]['attributes'].must_equal({ 'test_key' => 'test_value_a' })
        result[1]['key'].must_equal 'series_b'
        result[1]['tags'].must_include 'TAG B'
        result[1]['attributes'].must_equal({ 'test_key' => 'test_value_b' })
      end
    end
  end
end

