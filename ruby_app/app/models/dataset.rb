require 'forwardable'

class Dataset
  # CLASS METHODS
  #
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

    protected

    DEFAULT_ADAPTER = DatasetAdapters::TempoDBAdapter

    #def method_missing(name, *args, &block)
      #adapter.send(name, *args, &block)
    #end

    def adapter
      @adapter ||= DEFAULT_ADAPTER
    end
  end

  # INSTANCE METHODS

  extend Forwardable

  # Adapters should implement these instance methods (arity in comments)
  def_delegators :adapter_instance,
    :summary,  # 0
    :to_hash,  # 0
    :as_json,  # aliases to_hash
    :interval, # 0
    :series_names, # attr_reader
    :client, # attr_reader (is this necessary?)
    :options, # attr_reader
    :count, #attr_reader
    :function, # attr_reader
    :query_start, # attr_Reader,
    :query_stop # attr_Reader 



  def initialize(*args, &block)
    @adapter_instance = Dataset.adapter.new(*args, &block)
  end

  private

  attr_reader :adapter_instance

end
