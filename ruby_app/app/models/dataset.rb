class Dataset
  include Concerns::Tempo
  class << self

    def all
      tempodb_client.list_series
    end

    def multiple_series(start, stop, series, count = nil)
      start, stop  = fix_times(start, stop)
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

    def multiple_series_metadata(series)
      series.values.map do |key|
        tempodb_client.get_series(key)
      end
    end

    private

    # Performs a get-update-save transaction
    def with_series(series_key)
      tempodb_client.update_series(
        tempodb_client.get_series(series_key).tap {|series| yield series }
      )
    end

    def fix_times(*times)
      times.map(&method(:fix_time))
    end

    def fix_time(time)
      return if time.blank?
      if time !~ /\d{4,}\-/ 
        Time.at(time.to_f)
      else
        Time.parse(time)
      end
    end
  end

  attr_reader :series_names, :client, :options, :count,
    :function, :query_start, :query_stop

  extend Forwardable

  def_delegators :summary, :start, :stop, :rollup_period

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
    @interval     = opts[:interval]
  end

  def summary
    @summary ||= DatasetSupport::DatasetSummary.new(series_names, query_start, query_stop)
  end
  
  def to_hash
    #DatasetPresenter.new(return_hash, series, start, stop)
    return_hash
  end

  alias_method :as_json, :to_hash

  def interval
    @interval ||= DatasetSupport::Iso8601Duration.new(rollup_period(count)).to_s
  end

  private

  def series(sn)
    { key: "#{sn['key']}", values: [], tags: sn['tags'], attributes: sn['attributes'] }
  end

  def cursor
    @cursor ||= tempodb_client.read_multi(start, stop, options.merge(rollup_options))
  end

  def rollup_options
    return {} if count >= summary.max_count
    { rollup_function: function, rollup_period: interval }
  end

  def annotations
    @annotations ||= AnnotationSet.new(series_names).as_json
  end

  def return_hash
    @return_hash ||= {}.tap do |hash|
      cursor['series'].each { |sn| hash["#{sn['key']}"] = series(sn) }
      cursor.each do |datapoint|
        datapoint.value.each do |key, value|
          hash[key][:values] << { value: value, ts: datapoint.ts }
        end
      end

      annotations.each do |key, values|
        hash[key][:annotations] = values
      end

      # Sampling disabled (prefer tdb rollups)
      #hash.each do |_, series|
        #series[:values] = Sampling::RandomSample.sample(series[:values], 2000)
      #end
    end
  end
end
