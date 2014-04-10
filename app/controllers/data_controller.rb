class DataController < ApplicationController
  def show
    # respond_to do |format|
      client = get_tempodb_client
      @key = params[:key]
      # key = args[:key] || 'my-random-key'
      key = @key

      #Choose arbitrarily early time for first in the series
      start = Time.utc(1999, 1, 1)

      #Choose arbitrarily late time for last in the series
      stop = Time.utc(2020, 1, 1)

      keys = [key]

      #More details here on reading data from TempoDB: https://tempo-db.com/docs/api/read/
      #returned_data = client.read(start, stop, :keys => keys, :interval => "PT1S")
      returned_data = client.read(start, stop, :keys => keys, :interval => "raw")
      data = returned_data[0].data
      data.each { |d|
        puts "#{d.ts}\t\t%.5f" % d.value
      }
      p_array = []
      p = Payload.new(key, data)
      p_array << p
      # format.json {render :json => data}
      render :json => p_array
    # end
  end

  class Payload
    def initialize(key, values_array)
      # Instance variables
      @key = key
      @values = values_array
    end
  end

  private
  def get_tempodb_client
    TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
  end
end
