class Api::V1::QueueUploadsController < ApplicationController

  def create
    upload = current_user.uploads.create(filepath: params[:filepath])
    ProcessUploadWorker.perform_async(upload.id)
    render json: upload
  end

end
