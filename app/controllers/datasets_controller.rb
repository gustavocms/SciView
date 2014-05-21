class DatasetsController < ApplicationController
  respond_to :json

  # return a list of available series
  def index
    # respond_with Dataset.all(params[:id])
    respond_with Dataset.all
  end

  def multiple
    start = Time.parse(params[:start_time]) if params[:start_time]
    stop = Time.parse(params[:stop_time]) if params[:stop_time]
    dataset = Dataset.multiple_series(start, stop, params.select { |k,v| k.to_s =~ /series/ && v.present? })
    #dataset.count = params[:count].to_i if params[:count]
    respond_with dataset    
  end

  def show
    dataset = Dataset.for_series(params[:id])
    dataset.start = Time.parse(params[:start_time]) if params[:start_time]
    dataset.stop = Time.parse(params[:stop_time]) if params[:stop_time]
    dataset.count = params[:count].to_i if params[:count]
    respond_with dataset
  end
end
