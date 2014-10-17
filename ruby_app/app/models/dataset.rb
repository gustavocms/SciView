require 'forwardable'

class Dataset
  # CLASS METHODS
  #
  class << self
    extend Forwardable

    # The following should be implemented as class methods on the 
    # adapter.
    def_delegators :adapter, 

      # Args: options = {}
      # Should be enumerable class responding to as_json.
      # Members of result array are of the form
      # { 
      #   "id"         => "abcdef12345",
      #   "key"        => "my-sin-key",
      #   "name"       => "",
      #   "attributes" => {},
      #   "tags"       => []
      # }
      #
      :all,

      # Args: (start, stop, series, count = nil)
      # Calls to_hash on a new instance.
      # `series` is a hash of the form { series_1: 'test' }
      #
      # Returns a hash of the form
      # { 
      #   'test' => {
      #     key: 'test',
      #     values: [
      #       { :value => 1673, :ts => <TimeObject> },
      #       { ... },
      #       ...
      #     ],
      #     tags: ["TEST", ...],
      #     attributes: {}
      #   }
      # }
      :multiple_series,

      # Args: (series_new)
      # `series_new` is a HashWithIndifferentAccess of the form
      # {
      #   id: "abcd12345",
      #   key: "test",
      #   name: "",
      #   attributes: {},
      #   tags: ["TEST"...]
      # }
      #
      # Returns the updated series object.
      :update_series,

      # Args: (
      #   series_key, (string)
      #   attributes  (string)
      #   value       (string)
      #   
      # Returns the updated series object. 
      :update_attribute,

      # Args: (
      #   series_key, (string)
      #   attribute,  (string)
      #
      # Returns the updated series object.
      :remove_attribute,

      # Args:
      #   series_key, (string)
      #   tag (string)
      #
      # Returns the updated series object.
      :add_tag,

      # Args:
      #   series_key, (string)
      #   tag (string)
      #
      # Returns the updated series object.
      :remove_tag,

      # deprecated
      :for_series,

      # Args: key (string)
      # Returns the series object.
      :series_metadata,

      # Args: series - hash of the form: 
      # { series_1: 'test' }
      # Returns an array of series objects.
      :multiple_series_metadata


    def use_adapter(klass)
      @adapter = klass
    enlac

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
