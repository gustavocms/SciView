class Dataset
  include Concerns::Tempo
  class<<self

    def all
      tempodb_client.list_series
    end

    def multiple_series(start, stop, series, count=nil)
      start ||= Time.utc(1999, 1, 1)
      stop ||= Time.utc(2020, 1, 1)

      series_names = series.values

      options = {}

      options.merge!(keys: series_names)
      options.merge!(count: count) if count
      cursor = tempodb_client.read_multi(start, stop, options)

      return_hash = {}

      cursor['series'].each do |sn|
        return_hash.merge!(sn['key'].to_s => {key: sn['key'].to_s, values: [], tags: sn['tags'], attributes: sn['attributes']})
      end

      cursor.each do |datapoint|
        j = datapoint.as_json
        serie = return_hash[j['value'].keys[0]]
        serie[:values] << { value: j['value'].values[0], ts: j['ts'] }
      end

      return_hash
    end

    def update_attribute(series_key, attribute, value)
      series = tempodb_client.get_series(series_key)
      series.attributes[attribute] = value
      tempodb_client.update_series(series)
    end

    def remove_attribute(series_key, attribute)
      series = tempodb_client.get_series(series_key)
      series.attributes = series.attributes.except(attribute)
      tempodb_client.update_series(series)
    end

    def add_tag(series_key, tag)
      series = tempodb_client.get_series(series_key)
      series.tags.push(tag)
      tempodb_client.update_series(series)
    end

    def remove_tag(series_key, tag)
      series = tempodb_client.get_series(series_key)
      series.tags.delete(tag)
      tempodb_client.update_series(series)
    end

    def for_series(name)
      raise('this method is deprecated')
      #new(name)
    end
  end

  attr_accessor :start, :stop, :count

  def initialize(series_name)
    @client = tempodb_client
    @key = URI.decode(series_name)

    # Find start and stop times based on first and last single values
    past = Time.utc(1999, 1, 1)
    future = Time.utc(2020, 1, 1)
    @start = @client.single_value(@key, ts: past, direction: 'after').data.ts
    @stop = @client.single_value(@key, ts: future, direction: 'before').data.ts
  end


  def as_json(opts = {})
    if count
      opts[:rollup_period] = "PT#{"%.2f" % ((@stop - @start) / count)}S"
      opts[:rollup_function] = 'mean'
    end

    [{ key: @key, values: tempodb_client.read_data(@key, @start, @stop, opts)}]
  end
end
