require 'rake' # provides 'pathmap'

class Api::V1::QueueUploadsController < ApplicationController

  def create
    upload = current_user.uploads.create(filepath: params[:filepath])

    job_id = CsvUploadWorker.perform_async(series_name, params[:filepath])
    puts "JOB_ID #{job_id}"

    render json: upload
  end

  private

  def series_name
    @series_name ||= params[:series_name].presence || params[:filename].pathmap("%n")
  end

end
