module DatasetAdapters
  class InfluxAdapter
    class << self

      def all(options = {})
        (db.query('list series')).map do |name, value|
          {
            "id"         => digest(name),
            "key"        => name,
            "name"       => "",
            "attributes" => {},
            "tags"       => []
          }
        end
      end

      def multiple_series
        raise NotImplementedError
      end

      def update_series
        raise NotImplementedError
      end

      def update_attribute
        raise NotImplementedError
      end

      def remove_attribute
        raise NotImplementedError
      end

      def add_tag
        raise NotImplementedError
      end

      def remove_tag
        raise NotImplementedError
      end

      def for_series
        raise NotImplementedError
      end

      def series_metadata
        raise NotImplementedError
      end

      def multiple_series_metadata
        raise NotImplementedError
      end

      protected

      def db
        @db ||= InfluxDB::Client.new(INFLUX_DB_NAME)
      end

      private

      def digest(str)
        Digest::SHA1.hexdigest(str)
      end
    end

    # INSTANCE METHODS
   
    attr_reader :client, :options, :count, :function,
                :query_start, :query_stop, :series_names

    def initialize
      raise NotImplementedError
    end

    def summary
      raise NotImplementedError
    end

    def to_hash
      raise NotImplementedError
    end
    alias_method :as_json, :to_hash

    def interval
      raise NotImplementedError
    end
  end
end
