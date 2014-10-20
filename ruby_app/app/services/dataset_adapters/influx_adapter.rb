module DatasetAdapters
  class InfluxAdapter
    class << self

      def all(options = {})
        db.query('list series').map do |key, value|
          series_meta_template(key, value)
        end
      end

      # SAME IMPLEMENTATION - EXTRACT BASE CLASS
      def multiple_series(start, stop, series_hash, count = nil)
        start, stop = fix_times(start, stop)
        new(series_hash, { start: start, stop: stop, count: count }).to_hash
      end

      def update_series(series_hash = {})
        raise NotImplementedError
      end

      def update_attribute
        raise NotImplementedError
      end

      def remove_attribute
        raise NotImplementedError
      end

      def add_tag(key, tag_string)
        with_series(key) do |series|
          series.tags << tag_string
        end
      end

      def remove_tag
        raise NotImplementedError
      end

      def for_series
        raise NotImplementedError
      end

      def series_metadata(key)
        series_meta_template(key)
      end

      def multiple_series_metadata
        raise NotImplementedError
      end

      def db
        @db ||= InfluxDB::Client.new(INFLUX_DB_NAME)
      end
      alias_method :database, :db

      private

      def digest(str)
        Digest::SHA1.hexdigest(str)
      end

      # get-update-save transaction
      def with_series(key)
        series_meta_delegate(key).tap { |meta| yield meta }.save
      end
      
      def series_meta_template(key, value = nil) # don't yet know what "value" is
        series_meta_delegate(key).as_json
      end

      def series_meta_delegate(key)
        MetadataDelegate.find_or_initialize_by(key: key)
      end

      # SAME IMPLEMENTATION - EXTRACT BASE CLASS
      def fix_times(*times)
        times.map(&method(:fix_time))
      end

      # SAME IMPLEMENTATION - EXTRACT BASE CLASS
      def fix_time(time)
        return if time.blank?
        if time !~ /\d{4,}\-/ 
          Time.at(time.to_f)
        else
          Time.parse(time)
        end
      end
    end

    # INSTANCE METHODS
   
    attr_reader :client, :options, :count, :function,
                :query_start, :query_stop, :series_names

    def initialize(series_hash, options = {})
      @series_names = series_hash.values
      @options      = options
    end

    def summary
      raise NotImplementedError
    end

    def to_hash
      query("SELECT * FROM #{series_names.join(", ")}").each_with_object({}) do |(key, values), hash|
        hash[key] = series_hash(key, values)
      end
    end
    alias_method :as_json, :to_hash

    def interval
      raise NotImplementedError
    end

    private

    DEFAULT_PRECISION = "u" # microseconds (smallest supported by InfluxDB)

    def query(query_string)
      db.query(query_string, DEFAULT_PRECISION)
    end

    def series_hash(key, values)
      {
        key: key,
        values: map_values(values),
        tags: [],
        attributes: {}
      }
    end

    # TODO: enable other precisions here
    def map_values(values, precision = DEFAULT_PRECISION)
      values.reverse_each.map do |value|
        { ts: Time.at(value["time"] / 1000000), value: value["value"] }
      end
    end

    def db
      self.class.db
    end
  end
end
