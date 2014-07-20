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

  attr_reader :series_names, :client, :options, :count,
    :function, :interval, :query_start, :query_stop

  extend Forwardable

  def_delegators :summary, :start, :stop

  # series: a hash of the form { series_1: 'sample_abcdef123' }
  # options: start
  #          stop
  #          count
  def initialize(series, opts = {})
    @series_names = series.values
    @query_start        = opts[:start] || Time.utc(1999)
    @query_stop         = opts[:stop]  || Time.utc(2020)
    @count        = Integer(opts[:count] || 2000)
    @options      = { keys: series_names }.select {|_,v| v }
    @function     = opts[:function] || "mean"
    @interval     = opts[:interval] || "PT0.01S"
  end

  def summary
    @summary ||= DatasetSummary.new(series_names, query_start, query_stop)
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
    puts options.merge(rollup_options)
    puts start.inspect
    puts stop.inspect
    c = tempodb_client.read_multi(start, stop, options.merge(rollup_options))
    puts "CURSOR GOT #{Time.now - t}"
    return c
  end

  def rollup_options
    #return {} if count >= summary.max_count
    { rollup_function: function, rollup_period: interval }
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

# Provides a simple interface to query metadata about time series,
# including real start and stop times (not currently available as an API endpoint).
# Used internally in Dataset.
class DatasetSummary
  attr_reader :series_names

  include Concerns::Tempo

  attr_reader :series_names, :query_start, :query_stop
  def initialize(series_names, start, stop)
    @series_names = Array(series_names)
    @query_start  = start
    @query_stop   = stop
  end

  def rollup_period(desired_number_of_segments)
    length_in_seconds / desired_number_of_segments
  end

  def length_in_seconds
    (stop - start).to_f
  end

  def time_extents
    [start, stop]
  end

  def start
    starts.min
  end

  def stop
    stops.max
  end

  def count
    _attr(:count).inject(:+)
  end

  def max
    _max(:max)
  end

  def min
    _min(:min)
  end
  alias_method :keys, :series_names

  private

  def starts
    @starts ||= extents(query_start, 'after')
  end

  def stops
    @stops ||= extents(query_stop, 'before')
  end

  def extents(time, direction)
    tempodb_client.multi_series_single_value({
      keys: series_names,
      ts: time,
      direction: direction
    }).map {|t| t.data.ts }
  end

  def series_summaries
    @series_summaries ||= series_names.map do |name|
      SeriesSummary.new(name, query_start, query_stop)
    end
  end

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

require 'forwardable'
class SeriesSummary
  extend Forwardable
  include Concerns::Tempo
# 
  class << self
    def hash_attr(accessor, *args)
      args.each do |arg|
        define_method(arg) do
          send(accessor).fetch("#{arg}", nil)
        end
      end
    end
  end

  attr_reader :series_name, :query_start, :query_stop
  def initialize(series_name, start, stop)
    @series_name = series_name
    @query_start = start
    @query_stop = stop
  end

  def_delegators :_summary, :summary, :series
  hash_attr :summary, :count, :mean, :min, :max, :stddev, :sum
  hash_attr :series, :id, :key, :name, :tags, :attributes

  private

  def _summary
    @_summary ||= tempodb_client.get_summary(series_name, query_start, query_stop)
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
