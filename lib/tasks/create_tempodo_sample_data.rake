namespace :data do

  desc 'lists all series in TempoDB (or at least the first 5000)'
  task :list_series do
    client = TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])
    series_list = client.get_series()
    puts series_list
    puts series_list.count

  end
  desc 'creates new series and sample data for tempodb'
  task :create_series do
    client = get_tempodb_client

    key = 'my-custom-key'
    create_series(client, key)

  end

  desc 'Creates a bunch of tempodb series'
  task :create_multiple_series, :key_base, :count do |t, args|
    client = get_tempodb_client
    count = args[:count].to_i
    key_base = args[:key_base]

    abort("Aborting: :key_base was blank!") if key_base.blank?
    abort("Aborting: :count was not greater than 0!") if count <= 0

    start_time = Time.now

    for i in 0..count
      key = format_key(key_base, i)
      create_series(client, key)
      puts "#{Time.now}\t#{i}"
    end

    end_time = Time.now

    puts "Start time: #{start_time}"
    puts "End time: #{end_time}"
    puts "Duration: #{end_time - start_time} seconds"

  end


  desc 'creates series and sample data for tempodb using random numbers'
  task :create_random_series do
    client = get_tempodb_client

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
    client = get_tempodb_client

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
        value = Math.sin( Math::PI / duration * NUM_OF_SINES * i )
        data << TempoDB::DataPoint.new(Time.at(time_base + i), value)

      end
      client.write_key(series1.key, data)
    else
      puts "already exists, need to run rake delete_series"
    end

  end


  desc 'deletes a tempodb series'
  task :delete_series, :key do |t, args|

    client = get_tempodb_client
    key = args[:key]
    delete_series(client, key)

  end

  desc 'deletes multiple tempodb series'
  task :delete_multiple_series, :key_base, :count do |t, args|

    client = get_tempodb_client
    count = args[:count].to_i
    key_base = args[:key_base]

    abort("Aborting: :key_base was blank!") if key_base.blank?
    abort("Aborting: :count was not greater than 0!") if count <= 0

    start_time = Time.now

    for i in 0..count
      key = format_key(key_base, i)
      delete_series(client, key)
      puts "#{Time.now}\t#{i}"
    end

    end_time = Time.now

    puts "Start time: #{start_time}"
    puts "End time: #{end_time}"
    puts "Duration: #{end_time - start_time} seconds"


  end


  desc 'reads series and sample data for tempodb using random numbers'
  task :read_series, :key do |t, args|

    client = get_tempodb_client
    key = args[:key] || 'my-random-key'

    #Choose arbitrarily early time for first in the series
    start = Time.utc(1999, 1, 1)

    #Choose arbitrarily late time for last in the series
    stop = Time.utc(2020, 1, 1)

    keys = [key]

    #More details here on reading data from TempoDB: https://tempo-db.com/docs/api/read/
    #returned_data = client.read(start, stop, :keys => keys, :interval => "PT1S")
    returned_data = client.read(start, stop, :keys => keys, :interval => "raw")
    data = returned_data[0].data
    data.each { |d|
      puts "#{d.ts}\t\t%.5f" % d.value
    }

  end




  private
  def random_range (min, max)
    rand * (max-min) + min
  end

  def create_series(client, key)
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

  def delete_series(client, key)
    if key.blank?
      abort("Aborting: Key was blank!")
    end
    puts "Deleting: #{key}"
    summary = client.delete_series(key: key)
    puts "Summary: #{summary.inspect}"
  end

  def format_key(key_base, i)
    "#{key_base}-%05d" % i
  end

  def get_tempodb_client
    TempoDB::Client.new(ENV['TEMPODB_API_KEY'], ENV['TEMPODB_API_SECRET'])

  end



end