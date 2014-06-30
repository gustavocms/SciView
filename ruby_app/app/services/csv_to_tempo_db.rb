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
      multi.add(series_name, data.map {|time, amplitude| TempoDB::DataPoint.new(date + time.to_i, amplitude.to_i) })
    end
  end

  # not necessary
  #def series
  #  @series ||= create_series(series_name, tags_and_attributes)
  #end

  private

  def date
    @date ||= Time.utc(2014,1,1)
  end

  def data
    @data ||= CSV.read(filepath) # :headers should be an option
  end
end
