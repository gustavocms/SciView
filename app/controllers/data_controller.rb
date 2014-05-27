class DataController < ApplicationController
  def show
    client = tempodb_client
    key = URI.decode(params[:key])

    # Choose arbitrarily early time for first in the series
    start = Time.utc(1999, 1, 1)

    # Choose arbitrarily late time for last in the series
    stop = Time.utc(2020, 1, 1)

    # More details here on reading data from TempoDB: https://tempo-db.com/docs/api/read/

    response = client.read_data(key, start, stop, interval: 'raw')
    data = []
    response.each { |d| data << d }

    render json: [Payload.new(key, data)]
  end

  def list_series
    client = tempodb_client
    series_list = client.get_series
    render json: series_list
  end

  class Payload
    def initialize(key, values_array)
      # Instance variables
      @key = key
      @values = values_array
    end
  end

  private

  def tempodb_client
    TempoDB::Client.new(ENV['TEMPODB_API_ID'],
                        ENV['TEMPODB_API_KEY'],
                        ENV['TEMPODB_API_SECRET'])
  end
end
