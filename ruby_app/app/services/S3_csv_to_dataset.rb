class S3CsvToDataset < CsvToDataset
  private

  def raw_data
    @raw_data ||= CSV.parse(S3_BUCKET.objects[filepath].read)
  end
end
