require_relative '../../test_helper'

TEST_DB_NAME = "__sciview_test"

describe DatasetAdapters::InfluxAdapter do
  before do
    # Delete and recreate the database before every test.
    InfluxDB::Client.new.tap do |influx|
      influx.delete_database(TEST_DB_NAME) if influx.get_database_list.any? {|db| db["name"] == TEST_DB_NAME }
      influx.create_database(TEST_DB_NAME)
    end
  end

  let(:client){ InfluxDB::Client.new(TEST_DB_NAME) }
  let(:adapter){ DatasetAdapters::InfluxAdapter }

  describe :all do
    specify "empty list" do
      client.all.tap do |result|
        result.must_be_instance_of Array
        result.must_be_empty
      end
    end

    specify "with series" do
      client.write_point('test_series', { time: Time.now.to_i, value: 100 })
    end
  end
end

