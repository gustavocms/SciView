class CsvUploadWorker
  include Sidekiq::Worker

  def perform(series_name, s3_path)
    S3CsvToDataset.new(s3_path).tap do |csv|
      csv.series_name = series_name
      csv.save!
    end
  end
end
