require 'rake' # provides String#pathmap
require 'forwardable'
require 'csv'

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
  # There are several strategies to be considered here
  def save!
    write_multi do |multi|
      multi.add(series_name, data)
    end
  end

  private

  def date
    @date ||= Time.utc(2014,1,1)
  end

  def raw_data
    @raw_data ||= CSV.read(filepath) # :headers should be an option
  end

  def data
    raw_data.map do |time, amplitude|
      datapoint_wrapper.new(date + time.to_i, amplitude.to_i)
    end
  end

  def datapoint_wrapper
    @datapoint_wrapper || TempoDB::DataPoint
  end
end
