namespace :influx do
  desc 'create new series for InfluxDB'
  task :create_series => :environment do
    name = "influx_#{SecureRandom.hex(3)}"
    client = DatasetAdapters::InfluxAdapter.send(:db)
    FakeData.generate.each do |ts, value|
      client.write_point(name, { time: (ts.to_f * 1000).to_i, value: value }, false, 'ms')
    end

    puts name
  end
end
