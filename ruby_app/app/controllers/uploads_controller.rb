require 'rake'

class UploadsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  def create
    CsvToTempoDb.new(csv.path).tap do |c|
      c.series_name = series_name
      c.save!
    end

    Chart.for_datasets(series_1: series_name).tap do |chart|
      chart.user = current_user
      chart.save
      redirect_to chart
    end
  end

  private

  def csv
    @csv ||= params[:csv]
  end

  def series_name
    @series_name ||= params[:series_name] || csv.original_filename.pathmap("%n")
  end
end
