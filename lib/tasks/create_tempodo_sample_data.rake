TEMPODB_API_KEY = ENV['TEMPODB_API_KEY']
TEMPODB_API_SECRET = ENV['TEMPODB_API_SECRET']

desc 'creates new series and sample data for tempodb'
task :create_tempodb_series do
  client = TempoDB::Client.new(TEMPODB_API_KEY, TEMPODB_API_SECRET)

  key = 'my-custom-key'
  series1 = client.get_series(key: key)
  if series1.empty?
    puts "#{key} series was empty--creating new one!"
    series1 = client.create_series(key)
    data = [
        TempoDB::DataPoint.new(Time.utc(2012, 1, 1, 1, 0, 0), 12.34),
        TempoDB::DataPoint.new(Time.utc(2012, 1, 1, 1, 1, 0), 1.874),
        TempoDB::DataPoint.new(Time.utc(2012, 1, 1, 1, 2, 0), 21.52)
    ]
    client.write_key(series1.key, data)

  else
    puts "#{key} Series was not empty!"
    start = Time.utc(2012, 1, 1)
    stop = Time.utc(2012, 1, 2)
    keys = [key]
    returned_data = client.read(start, stop, :keys => keys, :interval => "1hour", :function => "max")
    p returned_data
  end

end

desc 'creates series and sample data for tempodb using random numbers'
task :create_random_series do
  client = TempoDB::Client.new(TEMPODB_API_KEY, TEMPODB_API_SECRET)

  key = 'my-random-key'
  series1 = client.get_series(key: key)
  if series1.empty?
    puts "#{key} series was empty--creating new one!"
    series1 = client.create_series(key)
    data = []
    time_base = Time.now.to_f

    duration = 60 * 10 # 10 minutes
    for i in 0..duration

      data << TempoDB::DataPoint.new(Time.at(time_base + i), random_range(1, 100))

    end
    puts data
    client.write_key(series1.key, data)
  end

end


desc 'creates series and sample data for tempodb to look like a sin wave'
task :create_sin_series do
  client = TempoDB::Client.new(TEMPODB_API_KEY, TEMPODB_API_SECRET)

  key = 'my-sine-key'
  series1 = client.get_series(key: key)
  if series1.empty?
    puts "#{key} series was empty--creating new one!"
    series1 = client.create_series(key)
    data = []
    time_base = Time.now.to_f

    duration = 60 * 10 # 10 minutes
    NUM_OF_SINES = 10

    Math::PI * 2
    for i in 0..duration
      value = Math.sin( Math::PI * duration * NUM_OF_SINES * i )
      data << TempoDB::DataPoint.new(Time.at(time_base + i), value)

    end
    puts data
    client.write_key(series1.key, data)
  end

end


desc 'reads series and sample data for tempodb using random numbers'
task :read_random_series, :key do |t, args|

  client = TempoDB::Client.new(TEMPODB_API_KEY, TEMPODB_API_SECRET)
  key = args[:key] || 'my-random-key'

  #Choose arbitrarily early time for first in the series
  start = Time.utc(1999, 1, 1)

  #Choose arbitrarily late time for last in the series
  stop = Time.utc(2020, 1, 1)

  keys = [key]

  #More details here on reading data from TempoDB: https://tempo-db.com/docs/api/read/
  returned_data = client.read(start, stop, :keys => keys, :interval => "PT1S")
  data = returned_data[0].data
  data.each { |d|
    puts "#{d.ts}\t\t%.2f" % d.value
  }

end



private
def random_range (min, max)
  rand * (max-min) + min
end