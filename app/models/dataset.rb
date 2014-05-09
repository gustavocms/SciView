class Dataset
  class<<self
    def all
      TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET']).get_series
    end

    def for_series(name)
      new(name)
    end
  end

  attr_accessor :start, :stop, :count

  def initialize(series_name)
    @client = TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
    @key = URI.decode(series_name)

    # Choose arbitrary time for start and stop by default
    @start = Time.utc(1999, 1, 1)
    @stop = Time.utc(2020, 1, 1)
  end

  def as_json(opts = {})
    opts[:keys] = [@key]

    if count
      opts[:interval] = "#{((@stop - @start) / 60.0) / count}min"
      opts[:function] = 'mean'
    else
      opts[:interval] = 'raw'
    end

    [{ key: @key,
       values: @client.read(@start, @stop, opts).first.data }]
  end
end
