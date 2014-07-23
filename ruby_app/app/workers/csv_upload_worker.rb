class CsvUploadWorker
  include Sidekiq::Worker

  def perform(series_name, tempfile_path)
    CsvToTempoDb.new(tempfile_path).tap do |csv|
      csv.series_name = series_name
      csv.save!
      csv.wait_for_tempo_db
    end
  end
end
