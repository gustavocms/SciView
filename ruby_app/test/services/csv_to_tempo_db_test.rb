require 'minitest/autorun'
require 'rr'

module Concerns
  module Tempo
  end
end

require_relative '../../app/services/csv_to_tempo_db'

class MockTempoSeries < Struct.new(:name, :attributes)
end

class MockTempoDataPoint < Struct.new(:datetime, :value)
end

class MockTempoStore
  def add(series_name, datapoints)
    Array(datapoints).each do |dp|
      data[series_name] << dp
    end
  end

  def data
    @data ||= Hash.new {|h,k| h[k] = [] }
  end
end

class MockTempoDBClient
  def create_series(name, attrs)
    @series = MockTempoSeries.new(name, attrs)
  end

  def write_multi
    yield store
  end

  def store
    @store ||= MockTempoStore.new
  end
end

describe CsvToTempoDb do
  let(:converter){ CsvToTempoDb.new('fixtures/test_data.csv', { tags: %w[foo bar]}, MockTempoDBClient.new)}
  before do
    converter.instance_variable_set(:@datapoint_wrapper, MockTempoDataPoint)
    converter.save!
  end

  it 'saves the data to the service' do
    converter.data_store.store.data.keys.must_equal ["test_data"]
    converter.data_store.store.data["test_data"].count.must_equal 10
  end

  it 'converts the time into ISO 8601 format' do
    converter.data_store.store.data["test_data"].first.tap do |datapoint|
      datapoint.datetime.must_equal Time.iso8601("2014-07-01T09:00:00.001Z")
    end
  end
end
