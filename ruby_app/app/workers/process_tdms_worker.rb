class ProcessTdmsWorker
  include Sidekiq::Worker


  def perform(tdms_file_id)
    #TODO process file here
    tdms = TdmsFile.find(tdms_file_id)
    logger.debug "Processing file #{tdms.filepath}"
  end

end