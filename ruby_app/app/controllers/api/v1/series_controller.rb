class Api::V1::SeriesController < ApplicationController
  respond_to :json

  def index
    render json: Dataset.all(params)
  end

  def show
    render json: Dataset.series_metadata(params[:id])
  end

end
