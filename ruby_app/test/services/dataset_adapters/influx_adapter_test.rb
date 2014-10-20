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
end

