require 'forwardable'
require 'rake'
require 'csv'
require 'time'

class CsvToDataset
  extend Forwardable

  attr_reader :filepath, :data_store, :series, :tags_and_attributes
  attr_accessor :series_name

  def_delegators :data_store, :create_series, :write_series

  def initialize(filepath, tags_and_attributes = {}, data_store = Dataset)
    @filepath            = filepath
    @series_name         = filepath.pathmap('%n')
    @tags_and_attributes = tags_and_attributes
    @data_store          = data_store
  end

  def save!
    write_series(series_name, raw_data)
  end

  private

  def raw_data
    @raw_data ||= CSV.read(filepath)
  end
end
