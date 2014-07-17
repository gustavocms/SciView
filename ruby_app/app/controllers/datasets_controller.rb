class DatasetsController < ApplicationController
  respond_to :json

  # return a list of available series
  def index
    # respond_with Dataset.all(params[:id])
    respond_with Dataset.all
  end

  def multiple
    dataset = Dataset.multiple_series(params[:start_time], params[:stop_time], params.select { |k,v| k.to_s =~ /series/ && v.present? }, params[:count])
    respond_with dataset
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
end
