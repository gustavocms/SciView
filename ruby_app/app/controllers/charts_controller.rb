class ChartsController < ApplicationController
  respond_to :json , :html

  def index
  end

  def create
    @chart = Chart.new()
    @chart.name = params[:name]
    @chart.series = params[:series]
    @chart.user = current_user
    if @chart.save
      render json:  @chart
    else
      render json:  @chart.errors, :status => 400
    end
  end

  def multiple
    @charts = Chart.for_datasets(params.select { |k,v| k.to_s =~ /series/ && v.present? })
  end

  def show
    @chart = Chart.find(params[:id])
  end
end
