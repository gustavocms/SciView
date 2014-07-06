require 'securerandom'
require 'csv'

CSV_SAMPLE_DATA_DIRECTORY = %{tmp/csv_sample_data}

class CSVSample

  def initialize(options = {})
    @options = options
  end

  def save!
    puts %{Find me in #{save_data_to_file}}
  end

  private

  def save_data_to_file
    _filename.tap do |filename|
      CSV.open(filename, 'w') do |csv|
        sample_rows.each {|sample| csv << sample }
      end
    end
  end

  def _filename
    %{#{CSV_SAMPLE_DATA_DIRECTORY}/sample_#{SecureRandom.hex(3)}_#{Time.now.to_i}.csv}
  end

  def sample_rows
    sample_datapoints.zip(timestamps).map do |dp, time|
      [time.strftime("%FT%T.%3N%z"), dp]
    end
  end

  def timestamps
    (0..Float::INFINITY).step(0.001).lazy.map {|t| start_time + t }
  end

  def start_time
    @start_time ||= Time.new(2014, 1, 1)
  end

  def sample_datapoints(generator = WhiteNoiseGenerator)
    generator.sample(10000)
  end
end

class WhiteNoiseGenerator
  class << self
    def sample(n)
      n.times.map { rand(1000) }
    end
  end
end

namespace :data do
  desc 'create a csv file with random data for TempoDB'
  task :create_csv => :create_csv_sample_folder do
    CSVSample.new.save!
  end

  task :create_csv_sample_folder do
    sh "mkdir -p tmp/csv_sample_data"
  end
end
