require 'rake' # provides 'pathmap'
require 'fileutils'

class UploadsController < ApplicationController
  before_filter :authenticate_user!

  def new
  end

  def create
    FileUtils.mkdir_p 'tmp/uploads'
    tmp = File.new(filepath, 'w')
    tmp.write(csv.read)
    job_id = CsvUploadWorker.perform_async(series_name, filepath)
    puts "JOB_ID #{job_id}"
    redirect_to_temp_chart
  end

  private

  def redirect_to_temp_chart
    redirect_to multiple_charts_path(series_1: series_name)
  end

  def create_chart_and_redirect
    Chart.for_datasets(series_1: series_name).tap do |chart|
      chart.user = current_user
      chart.save
      redirect_to chart
    end
  end

  def filename
    @filename ||= SecureRandom.hex(32)
  end

  def filepath
    "#{uploads_dir}/#{filename}"
  end

  def uploads_dir
    "tmp/uploads"
  end

  def csv
    @csv ||= params[:csv]
  end

  def series_name
    @series_name ||= params[:series_name].presence || csv.original_filename.pathmap("%n")
  end
end
