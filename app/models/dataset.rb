class Dataset
  class<<self

    def all
      tempodb_client.list_series
    end

    def for_series(name)
      new(name)
    end

    # @return TempoDB::Client
    def tempodb_client
      @tempodb_client ||= TempoDB::Client.new(ENV['TEMPODB_API_ID'],
                                              ENV['TEMPODB_API_KEY'],
                                              ENV['TEMPODB_API_SECRET'])
    end
  end

  attr_accessor :start, :stop, :count

  def initialize(series_name)
    @client = Dataset.tempodb_client
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

    [{ key: @key, values: @client.read_data(@key, @start, @stop, opts)}]
  end
end
