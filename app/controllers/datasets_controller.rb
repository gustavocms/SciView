class DatasetsController < ApplicationController
  respond_to :json

  def index
    respond_with Dataset.all
  end

  def show
    dataset = Dataset.for_series(params[:id])
    dataset.start = Time.parse(params[:start_time]) if params[:start_time]
    dataset.stop = Time.parse(params[:stop_time]) if params[:stop_time]
    dataset.count = params[:count].to_i if params[:count]
    respond_with dataset
  end
end
