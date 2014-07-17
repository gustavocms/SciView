class Dataset
  include Concerns::Tempo
  class << self

    def all
      tempodb_client.list_series
    end

    def multiple_series(start, stop, series, count=nil)
      new(series, { start: start, stop: stop, count: count }).to_hash
    end

    def update_attribute(series_key, attribute, value)
      with_series(series_key) {|series| series.attributes[attribute] = value }
    end

    def remove_attribute(series_key, attribute)
      with_series(series_key) do |series|
        series.attributes = series.attributes.except(attribute)
      end
    end

    def add_tag(series_key, tag)
      with_series(series_key) {|series| series.tags << (tag) }
    end

    def remove_tag(series_key, tag)
      with_series(series_key) {|series| series.tags.delete(tag) }
    end

    def for_series(name)
      raise('this method is deprecated')
    end

    private

    # Performs a get-update-save transaction
    def with_series(series_key)
      tempodb_client.update_series(
        tempodb_client.get_series(series_key).tap {|series| yield series }
      )
    end
  end

  attr_reader :series_names, :client, :options, :count, :start, :stop

  # series: a hash of the form { series_1: 'sample_abcdef123' }
  # options: start
  #          stop
  #          count
  def initialize(series, opts = {})
    @series_names = series.values
    @start        = opts[:start] || Time.utc(1999)
    @stop         = opts[:stop]  || Time.utc(2020)
    @count        = Integer(opts[:count] || 2000)
    @options      = { keys: series_names, count: count }.select {|_,v| v }
  end

  def summary
    @summary ||= DatasetSummary.new(series_names.map do |key| 
      SeriesSummary.new(tempodb_client.get_summary(key, start, stop))
    end)
  end
  
  def to_hash
    return_hash
  end

  private

  def series(sn)
    { key: "#{sn['key']}", values: [], tags: sn['tags'], attributes: sn['attributes'] }
  end

  def cursor
    @cursor ||= _get_cursor #tempodb_client.read_multi(start, stop, options.merge(rollup_options))
  end

  def _get_cursor
    puts "GET CURSOR #{t = Time.now}..."
    c = tempodb_client.read_multi(start, stop, options.merge(rollup_options))
    puts "CURSOR GOT #{Time.now - t}"
    return c
  end

  def rollup_options
    return {} if count >= summary.max_count
    { rollup_function: 'mean', rollup_period: "PT1M" }
  end

  def return_hash
    @return_hash ||= {}.tap do |hash|
      puts "SETTING SERIES... #{s = Time.now}"
      cursor['series'].each { |sn| hash["#{sn['key']}"] = series(sn) }
      puts "SERIES SET #{Time.now - s}"

      puts "RETRIEVING DATA... #{r = Time.now}"
      cursor.each do |datapoint|
        datapoint.value.each do |key, value|
          hash[key][:values] << { value: value, ts: datapoint.ts }
        end
      end
      puts "DATA RETRIEVED #{Time.now - r}"

      hash.each do |_, series|
        t = Time.now
        puts "SAMPLING STARTED..."
        series[:values] = Sampling::RandomSample.sample(series[:values], 2000)
        puts "SAMPLING ENDED (#{Time.now - t} seconds)"
      end
    end
  end

end

require 'forwardable'
class SeriesSummary
  extend Forwardable

  class << self
    def hash_attr(accessor, *args)
      args.each do |arg|
        define_method(arg) do
          send(accessor).fetch("#{arg}", nil)
        end
      end
    end
  end

  def initialize(summary)
    @summary = summary # expects TempoDB::SeriesSummary object / duck
  end

  def_delegators :@summary, :summary, :series, :start, :stop
  hash_attr :summary, :count, :mean, :min, :max, :stddev, :sum
  hash_attr :series, :id, :key, :name, :tags, :attributes

  # The time between datapoints, assuming an even distribution.
  # Unit: seconds
  def average_period
    time_extents / count
  end

  # Length of dataset in seconds
  def time_extents
    (stop - start).to_f
  end

  def rollup_period(desired_number_of_segments)
    time_extents / desired_number_of_segments
  end
end

class DatasetSummary
  def initialize(series_summaries)
    @series_summaries = Array(series_summaries)
  end

  def min
    _min :min
  end

  def max
    _max :max
  end

  def max_count
    _max :count
  end

  def count
    series_summaries.inject(0) {|sum, summary| sum + summary.count }
  end

  def keys
    _attr :key
  end

  def names
    _attr :name
  end

  def start
    _min :start
  end

  def stop
    _max :stop
  end

  def time_extents
    stop - start
  end

  # returns duration in seconds
  def rollup_period(desired_number_of_segments)
    time_extents / desired_number_of_segments
  end

  private

  attr_reader :series_summaries

  def _min(attribute)
    _attr(attribute).min
  end

  def _max(attribute)
    _attr(attribute).max
  end

  def _attr(attribute)
    series_summaries.map(&attribute)
  end
end

class Iso8601Duration
  attr_reader :seconds

  def initialize(seconds)
    @seconds = seconds
  end

  def to_s
    ""
  end
  alias_method :to_str, :to_s

end
