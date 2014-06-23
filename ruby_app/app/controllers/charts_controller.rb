class ChartsController < ApplicationController
  respond_to :html

  def index
  end

  def create
    @chart = Chart.for_datasets(params[:series])
    @chart.user = current_user
    @chart.save
  end

  def multiple
    @charts = Chart.for_datasets(params.select { |k,v| k.to_s =~ /series/ && v.present? })
  end

  def show
    @chart = Chart.find(params[:id])
  end
end
