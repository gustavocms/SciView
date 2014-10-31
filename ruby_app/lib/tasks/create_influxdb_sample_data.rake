namespace :influx do
  desc 'create new series for InfluxDB'
  task :create_series => :environment do
    name = "influx_#{SecureRandom.hex(3)}"
    client = DatasetAdapters::InfluxAdapter.send(:db)
    FakeData.generate.each do |ts, value|
      DatasetAdapters::InfluxAdapter.write_point(name, value, ts, 'ms')
    end

    puts name
  end
end
