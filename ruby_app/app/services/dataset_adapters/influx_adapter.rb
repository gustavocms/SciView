module DatasetAdapters
  class InfluxAdapter
    class << self
      def all
        raise NotImplementedError
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
