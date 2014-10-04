class ProcessUploadWorker
  include Sidekiq::Worker


  def perform(upload_id)
    #TODO process file here
    tdms = Upload.find(upload_id)
    logger.debug "Processing file #{tdms.filepath}"
  end

end