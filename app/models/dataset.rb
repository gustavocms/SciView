class Dataset
  include Concerns::Tempo
  class<<self
    def all
      tempodb_client.list_series
    end

    def multiple_series(start, stop, series, count = nil)
      start ||= Time.utc(1999, 1, 1)
      stop ||= Time.utc(2020, 1, 1)

      series_names = series.values

      options = { keys: series_names }
      options[:count] = count if count
      cursor = tempodb_client.read_multi(start, stop, options)

      return_hash = {}
      series_names.each do |sn|
        return_hash.merge!(sn.to_s => { key: sn.to_s, values: [] })
      end

      cursor.each do |datapoint|
        j = datapoint.as_json
        serie = return_hash[j['value'].keys[0]]
        serie[:values] << { value: j['value'].values[0], ts: j['ts'] }
      end

      return_hash
    end

    def for_series(name)
      new(name)
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
      opts[:rollup_period] = "PT#{'%.2f'.format((@stop - @start) / count)}S"
      opts[:rollup_function] = 'mean'
    end

    [{ key: @key, values: tempodb_client.read_data(@key, @start, @stop, opts) }]
  end
end
