class DatasetsController < ApplicationController
  respond_to :json

  def index
    respond_with Dataset.all
  end

  def show
    respond_with Dataset.for_series(params[:id])
  end
end
