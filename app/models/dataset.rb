class Dataset
  class<<self
    def all
      TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET']).get_series
    end

    def for_series(name)
      new(name)
    end
  end

  attr_accessor :start, :stop

  def initialize(series_name)
    @client = TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
    @key = URI.decode(series_name)

    # Choose arbitrary time for start and stop by default
    @start = Time.utc(1999, 1, 1)
    @stop = Time.utc(2020, 1, 1)
  end

  def as_json(opts = {})
    [{ key: @key,
       values: @client.read(@start, @stop, keys: [@key], interval: 'raw').first.data }]
  end
end
