class Api::V1::QueueTdmsFilesController < ApplicationController

  def create
    tdms_file = current_user.tdms_files.create(filepath: params[:filepath])
    ProcessTdmsWorker.perform_async(tdms_file.id)
    render json: tdms_file
  end

end
