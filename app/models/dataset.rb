class Dataset
  include Concerns::Tempo
  class<<self

    def all
      client = get_tempodb_client
      cursor = client.list_series()
      return_array = []
      cursor.each do |series|
        return_array << series
      end

      return_array.to_json
    end

    def for_series(name)
      new(name)
    end
  end

  attr_accessor :start, :stop, :count

  def initialize(series_name)
    @client = get_tempodb_client
    @key = URI.decode(series_name)

    # Choose arbitrary time for start and stop by default
    @start = Time.utc(1999, 1, 1)
    @stop = Time.utc(2020, 1, 1)
  end


  def as_json(opts = {})
    # opts[:keys] = [@key]

    if count
      opts[:interval] = "#{((@stop - @start) / 60.0) / count}min"
      opts[:function] = 'mean'
    else
      opts[:interval] = 'raw'
    end

    # [{ key: @key, values: @client.read(@start, @stop, opts).first.data }]
    [{ key: @key, values: get_data_array(@client, @key, @start, @stop, opts)}]
  end

  private

  # @param client [TempoDB::Client]
  def get_data_array(client, key, start, stop, opts)
    response = client.read_data(key, start, stop, opts)
    data = []
    response.each { |d| data << d}
    data
  end

end
