require 'forwardable'

class Dataset
  class << self
    extend Forwardable

    # The following should be implemented as class methods on the 
    # adapter.
    def_delegators :adapter, 
      :all,
      :multiple_series,
      :update_series,
      :update_attribute,
      :remove_attribute,
      :add_tag,
      :remove_tag,
      :for_series,
      :series_metadata,
      :multiple_series_metadata


    def use_adapter(klass)
      @adapter = klass
    end

    def config
      @config ||= {}
    end

    private

    DEFAULT_ADAPTER = DatasetAdapters::TempoDBAdapter

    #def method_missing(name, *args, &block)
      #adapter.send(name, *args, &block)
    #end

    def adapter
      @adapter ||= DEFAULT_ADAPTER
    end
  end
end
