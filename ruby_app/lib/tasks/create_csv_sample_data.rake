require 'securerandom'
require 'csv'
require_relative '../../app/services/fake_data'

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
        sample_datapoints.each {|time, dp| csv << [time.strftime("%FT%T.%3N%z"), dp] }
      end
    end
  end

  def _filename
    %{#{CSV_SAMPLE_DATA_DIRECTORY}/sample_#{SecureRandom.hex(3)}_#{Time.now.to_i}.csv}
  end

  def sample_datapoints
    FakeData.generate({
      generator: FakeData::Generators::VolatilityGenerator,
      count: 10000
    })
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
