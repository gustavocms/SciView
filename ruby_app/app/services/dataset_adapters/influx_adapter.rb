module DatasetAdapters
  class InfluxAdapter < Base
    PRECISION = {
      "s"  => 1,      # seconds
      "ms" => 1000,   # microseconds
      "u"  => 1000000 # microseconds
    }

    #DEFAULT_PRECISION = "u" # microseconds (smallest supported by InfluxDB)
    DEFAULT_PRECISION = "ms" # milliseconds (smallest supported by JavaScript)

    class << self
      def all(options = {})
        db.query('list series').map do |key, value|
          series_meta_hash(key, value)
        end
      end

      # SAME IMPLEMENTATION - EXTRACT BASE CLASS
      def multiple_series(start, stop, series_hash, count = nil)
        start, stop = fix_times(start, stop)
        new(series_hash, { start: start, stop: stop, count: count }).to_hash
      end

      def update_series(_series_hash = {})
        series_hash = HashWithIndifferentAccess.new(_series_hash)
        with_series(series_hash.fetch(:key)) do |series|
          series.tags            = series_hash[:tags] if series_hash[:tags]
          series.meta_attributes = series_hash[:attributes] if series_hash[:attributes]
        end
      end

      def update_attribute(key, attr_key, attr_value)
        with_series(key) { |series| series.meta_attributes[attr_key] = attr_value }
      end

      def remove_attribute(key, attr_key)
        with_series(key) { |series| series.delete(attr_key) }
      end

      def add_tag(key, tag_string)
        with_series(key) { |series| series.tags << tag_string }
      end

      def remove_tag(key, tag_string)
        with_series(key) { |series| series.tags.delete(tag_string) }
      end

      def series_metadata(key)
        series_meta_hash(key)
      end

      def multiple_series_metadata(series_hash)
        series_hash.values.map(&method(:series_metadata))
      end

      # NEW API
      def write_point(key, value, timestamp)
        db.write_point(key, { value: value, timestamp: timestamp.to_f })
      end

      def query(query_string, precision = DEFAULT_PRECISION)
        db.query(query_string.to_s, precision)
      end

      private

      # There appears to be an issue where instantiating the
      # client with a defined precision does not carry it into queries
      # as suggested by the documentation. Instead of accessing this
      # directly, use the public `query` method that automatically appends
      # the precision indicator to all queries.
      def db
        @db ||= InfluxDB::Client.new(INFLUX_DB_NAME, DEFAULT_PRECISION)
      end
      alias_method :database, :db

      def digest(str)
        Digest::SHA1.hexdigest(str)
      end

      # get-update-save transaction
      def with_series(key)
        series_meta_delegate(key).tap { |meta| yield meta }.save
      end
      
      def series_meta_hash(key, value = nil) # don't yet know what "value" is
        series_meta_delegate(key).as_json
      end

      def series_meta_delegate(key)
        MetadataDelegate.find_or_initialize_by(key: key)
      end
    end

    # INSTANCE METHODS
   
    attr_reader :client, :options, :count, :function,
                :query_start, :query_stop, :series_names

    # Series hash can be a hash (in which case the values are taken)
    # or an array 
    # or a single string
    def initialize(series_hash, options = {})
      @series_names = (series_hash.values rescue Array(series_hash))
      @options      = options
    end

    def summary
      raise NotImplementedError
    end

    def to_hash
      #query("SELECT * FROM #{sanitized_series_names} group by time(100000u)").each_with_object({}) do |(key, values), hash|
      query(InfluxSupport::QueryBuilder.new(keys: series_names)).each_with_object({}) do |(key, values), hash|
        hash[key] = series_hash(key, values)
      end
    end
    alias_method :as_json, :to_hash

    def interval
      raise NotImplementedError
    end

    def query(query_string)
      self.class.query(query_string)
    end

    private

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
        { ts: InfluxSupport::UTC.at(value["time"] / 1000.0), value: value["value"] }
      end
    end

    def db
      self.class.db
    end

    def sanitized_series_names
      series_names.map(&:inspect).join(", ")
    end
  end
end
