class ChartsController < ApplicationController
  respond_to :html

  def index
  end

  def show
    @chart = Chart.for_dataset(params[:id])
    respond_with @chart
  end
end
