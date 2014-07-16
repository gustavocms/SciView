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
      with_series(series_key) do |series|
        series.attributes[attribute] = value
      end
    end

    def remove_attribute(series_key, attribute)
      with_series(series_key) do |series|
        series.attributes = series.attributes.except(attribute)
      end
    end

    def add_tag(series_key, tag)
      with_series(series_key) do |series|
        series.tags.push(tag)
      end
    end

    def remove_tag(series_key, tag)
      with_series(series_key) do |series|
        series.tags.delete(tag)
      end
    end

    def for_series(name)
      raise('this method is deprecated')
    end

    private

    # Performs a get-update-save transaction
    def with_series(series_key)
      tempodb_client.get(series_key).tap do |series|
        yield series
        tempodb_client.update_series(series)
      end
    end
  end

  attr_accessor :start, :stop, :count
  attr_reader :client, :keys

  # def initialize(series_names)
  #   @client = tempodb_client
  #   @keys   = Array(series_names).map {|sn| URI.decode(sn) }

  #   # Find start and stop times based on first and last single values
  #   past = Time.utc(1999, 1, 1)
  #   future = Time.utc(2020, 1, 1)
  #   @start = @client.single_value(@key, ts: past, direction: 'after').data.ts
  #   @stop = @client.single_value(@key, ts: future, direction: 'before').data.ts
  # end

  # def as_json(opts = {})
  #   if count
  #     opts[:rollup_period] = "PT#{"%.2f" % ((@stop - @start) / count)}S"
  #     opts[:rollup_function] = 'mean'
  #   end

  #   [{ 
  #      key: @key, 
  #      values: Sampling::RandomSample.sample(tempodb_client.read_data(@key, @start, @stop, opts).to_a, 500)
  #   }]
  # end
  
  # series: a hash of the form { series_1: 'sample_abcdef123' }
  # options: start
  #          stop
  #          count
  attr_reader :series_names, :client, :options
  def initialize(series, opts = {})

    @series_names = series.values
    @start        = opts[:start] || Time.utc(1999)
    @stop         = opts[:stop] || Time.utc(2020)
    @options      = { keys: series_names, count: opts[:count] }.select {|_,v| v }
  end

  def summary
    @summary ||= DatasetSummary.new(client.get_summary(key, start, stop))
  end
  
  def to_hash
    return_hash
  end

  private

  def series(sn)
    { key: "#{sn['key']}", values: [], tags: sn['tags'], attributes: sn['attributes'] }
  end

  def cursor
    @cursor ||= tempodb_client.read_multi(start, stop, options)
  end

  def return_hash
    @return_hash ||= {}.tap do |hash|
      cursor['series'].each { |sn| hash["#{sn['key']}"] = series(sn) }
      cursor.each do |datapoint|
        datapoint.value.each do |key, value|
          hash[key][:values] << { value: value, ts: datapoint.ts }
        end
      end

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
class DatasetSummary
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

  private

end
