class DatasetsController < ApplicationController
  respond_to :json

  # return a list of available series
  def index
    # respond_with Dataset.all(params[:id])
    respond_with Dataset.all
  end

  def multiple
    respond_with_series do |data|
      { 
        data: data,
        permalink: permalink(data),
        series: series,
        start: start,
        stop: stop
      }
    end
  end

  def status
    if Dataset.new(series).summary.count > 0
      respond_with "ready"
    else
      respond_with "pending"
    end
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

  def metadata
    render json: Dataset.multiple_series_metadata(params.select { |k,v| k.to_s =~ /series/ && v.present? })
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

  def respond_with_series(&block)
    Dataset.multiple_series(start, stop, series, params[:count]).tap do |data|
      respond_with(yield data)
    end
  end

  def series
    params.select {|k,v| k.to_s =~ /series/ && v.present? }
  end

  def start
    Time.parse(params[:start_time]) if params[:start_time]
  end

  def stop
    Time.parse(params[:stop_time]) if params[:stop_time]
  end

  def permalink_params
    {}.tap do |p_params|
      p_params.merge!(series)
      p_params.merge!(start_time: start.to_f) if start
      p_params.merge!(stop_time: stop.to_f) if stop
    end
  end

  def permalink(data)
    puts permalink_params.inspect
    multiple_charts_path(permalink_params)
  end
end
