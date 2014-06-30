require 'minitest/autorun'

module Concerns
  module Tempo
  end
end

require_relative '../../app/services/csv_to_tempo_db'

class MockTempoSeries < Struct.new(:name, :attributes)
end

class MockTempoDBClient
  def create_series(name, attrs)
    MockTempoSeries.new(name, attrs)
  end
end

describe CsvToTempoDb do
  let(:converter){ CsvToTempoDb.new('fixtures/test_data.csv', { tags: %w[foo bar]}, MockTempoDBClient.new)}

  it 'sends the name, tags, and attributes to the data store' do
    converter.series.tap do |series|
      series.name.must_equal 'test_data'
      series.attributes.must_equal({ tags: %w[foo bar] })
    end
  end

  it 'saves the data to the service' do
    converter.save!

  end
end
