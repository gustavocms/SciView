module DatasetSupport

  # Provides a simple interface to query metadata about time series,
  # including real start and stop times (not currently available as a TempoDB API endpoint).
  # Used internally in Dataset.
  class DatasetSummary
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

    def max_count
      _max(:count)
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
      "PT#{seconds.round(3)}S"
    end
    alias_method :to_str, :to_s
  end
end
