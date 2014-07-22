require 'rake' # provides String#pathmap
require 'forwardable'
require 'csv'
require 'time' # for IS0-8601
# "%FT%T.%L%z" strftime string for ISO-8601 date, time with milliseconds, and utc offset

class CsvToTempoDb
  include Concerns::Tempo
  extend Forwardable

  attr_reader :filepath, :data_store, :series, :tags_and_attributes
  attr_accessor :series_name

  def_delegators :data_store, :create_series, :write_multi

  def initialize(filepath, tags_and_attributes = {}, data_store = tempodb_client)
    @filepath            = filepath
    @series_name         = filepath.pathmap('%n')
    @tags_and_attributes = tags_and_attributes
    @data_store          = data_store
  end

  # Sends the data to TempoDB.
  def save!
    write_multi do |multi|
      multi.add(series_name, data)
    end
  end

  # returns true when a certain threshold of points has been processed
  # by tempodb. Times out after 10 seconds.
  #
  # This is intended to be called by a background worker.
  def wait_for_tempo_db(proportion = 0.1) # note: 100% will probably not work
    20.times do
      sleep(0.5)
      tempodb_client.get_summary(series_name, Time.utc(1999), Time.utc(2020)).tap do |s|
        puts "#{series_name}: #{s.summary['count']} out of #{raw_data.length}"
        return true if (s.summary['count'] || 0) >= raw_data.length * proportion
      end
    end
  end

  private

  def iso8601(time, decimal_digits = 3)
    time.strftime("%FT%T.%#{decimal_digits}N%z")
  end

  def raw_data
    @raw_data ||= CSV.read(filepath) # :headers should be an option
  end

  def data
    raw_data.map do |time, amplitude|
      datapoint_wrapper.new(Time.parse(time), amplitude.to_i)
    end
  end

  def datapoint_wrapper
    @datapoint_wrapper || TempoDB::DataPoint
  end
end
