module InfluxSupport
  UTC = ActiveSupport::TimeZone.new("UTC")

  # Hash of options:
  # REQUIRED
  #   :keys => [array of strings] or :key => str
  class Base
    def initialize(options = {})
      @keys    = Array(options.fetch(:keys){ options.fetch(:key) })
      @options = options
    end

    private

    attr_reader :keys, :options
  end

  class QueryBuilder < Base
    #
    # OPTIONAL
    #   :count => int # desired number of points
    #
    def to_s
      [
        "select", 
        select_function, 
        "from", 
        sanitized_keys, 
        group_by_function, 
        time_extents
      ].compact.join(" ")
    end

    alias_method :to_str, :to_s

    private

    attr_reader :keys, :options

    def sanitized_keys
      keys.map(&:inspect).join(", ")
    end

    def select_function
      options.fetch(:select){ "*" }
    end

    def group_by_function
    end

    def time_extents
      [start_condition, stop_condition].compact.join(" and ").presence.tap do |str|
        str.prepend("where ") if str.present?
      end
    end

    def start
      @start ||= options[:start]
    end

    def start_condition
      "time > '#{format(start)}'" if start
    end

    def stop
      @stop ||= options[:stop]
    end

    def stop_condition
      "time < '#{format(stop)}'" if stop
    end

    def format(time)
      time.strftime("%Y-%m-%d %H:%M:%S.%3N")
    end
  end

  # Get counts and time extents of multiple-series groups.
  class Summary < Base
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
      raise NotImplementedError
    end

    def max_count
      raise NotImplementedError
    end

    def max
      raise NotImplementedError
    end

    def min
      raise NotImplementedError
    end

    private

    def stops
      @stops ||= extents_query(stops_query)
    end

    def stops_query
      "#{QueryBuilder.new(options)} limit 1"
    end

    def starts_query
      "#{stops_query} order asc"
    end

    def starts
      @starts ||= extents_query(starts_query)
    end

    def extents_query(str)
      query(str).map do |key, points|
        (points[0] || {}).fetch("time", nil)
      end.compact.map {|float| UTC.at(float / precision_denominator) }
    end

    def query(qstr)
      DatasetAdapters::InfluxAdapter.query(qstr, precision)
    end

    def query_start
      options[:start]
    end

    def query_stop
      options[:stop]
    end

    def precision
      @precision ||= options.fetch(:precision, DatasetAdapters::InfluxAdapter::DEFAULT_PRECISION)
    end

    def precision_denominator
      DatasetAdapters::InfluxAdapter::PRECISION[precision].to_f
    end
  end
end
