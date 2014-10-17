class Dataset
  class << self
    def use_adapter(klass)
      @adapter = klass
    end

    def config
      @config ||= {}
    end

    private

    DEFAULT_ADAPTER = DatasetAdapters::TempoDBAdapter

    def method_missing(name, *args, &block)
      adapter.send(name, *args, &block)
    end

    def adapter
      @adapter ||= DEFAULT_ADAPTER
    end
  end
end
