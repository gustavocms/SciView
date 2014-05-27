class ChartsController < ApplicationController
  respond_to :html

  def index
  end

  def multiple
    series_params = params.select { |k, v| k.to_s =~ /series/ && v.present? }
    @charts = Chart.for_datasets(series_params)
  end

  def show
    @chart = Chart.for_dataset(params[:id])
  end
end
