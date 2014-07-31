class ChartsController < ApplicationController
  respond_to :json , :html

  def index
  end

  def create
    @chart      = Chart.new()
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
    @charts = Chart.for_datasets(series_params)
  end

  def pending
    @redirect_url = multiple_charts_path(params)
    if tempo_db_ready?
      redirect_to @redirect_url
    else
      @check_url = status_datasets_path(params)
    end
  end

  def show
    @chart = Chart.find(params[:id])
  end

  private

  def tempo_db_ready?
    Dataset.new(series_params).summary.count > 0
    false
  end

  def series_params
    params.select {|k,v| k.to_s =~ /series/ && v.present? }
  end
end
