class DatasetsController < ApplicationController
  respond_to :json

  # return a list of available series
  def index
    # respond_with Dataset.all(params[:id])
    respond_with Dataset.all
  end

  def multiple
    respond_with Dataset.multiple_series(start, stop, series, params[:count])
  end

  def profile
    render text: (Flamegraph.generate do
      #Dataset.multiple_series(start, stop, series, params[:count])
      Dataset.new(series, { 
        start: start, 
        stop: stop, 
        count: params[:count], 
        interval: params[:interval],
        function: params[:function]
      }).to_hash
    end)
  end

  def show
    raise('this method is deprecated')
    # dataset = Dataset.for_series(params[:id])
    # dataset.start = Time.parse(params[:start_time]) if params[:start_time]
    # dataset.stop = Time.parse(params[:stop_time]) if params[:stop_time]
    # dataset.count = params[:count].to_i if params[:count]
    # respond_with dataset
  end

  private

  def series
    params.select {|k,v| k.to_s =~ /series/ && v.present? }
  end

  def start
    Time.parse(params[:start_time]) if params[:start_time]
  end

  def stop
    Time.parse(params[:stop_time]) if params[:stop_time]
  end
end
