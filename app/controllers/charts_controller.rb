class ChartsController < ApplicationController
  respond_to :html

  def index
  end

  def multiple
    @charts = Chart.for_datasets(params.select { |k,v| k.to_s =~ /series/ && v.present? })
  end

  def show
    @chart = Chart.for_dataset(params[:id])
  end
end
