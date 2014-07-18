class Dataset
  include Concerns::Tempo
  class << self

    def all
      tempodb_client.list_series
    end

    def multiple_series(start, stop, series, count=nil)
      start = fix_times(start)
      stop  = fix_times(stop)
    
      new_start = start || Time.utc(1999, 1, 1)
      new_stop  = stop || Time.utc(2020, 1, 1)

      series_names = series.values

      options = {}

      options.merge!(keys: series_names)
      options.merge!(count: count) if count
      cursor = tempodb_client.read_multi(new_start, new_stop, options)

      return_hash = {}

      cursor['series'].each do |sn|
        return_hash[sn['key'].to_s] = { key: sn['key'].to_s, values: [], tags: sn['tags'], attributes: sn['attributes'] }
      end


      cursor.each do |datapoint|
        datapoint.value.each do |key, value|
          return_hash[key][:values] << { value: value, ts: datapoint.ts } 
        end
      end

      return_hash.each do |_, series|
        t = Time.now
        puts "SAMPLING STARTED..."
        series[:values] = Sampling::RandomSample.sample(series[:values], 2000)
        puts "SAMPLING ENDED (#{Time.now - t} seconds)"
      end

      new(return_hash, series, start, stop)
    end

    def multiple_series_metadata(series)
      series_data = []

      series.values.each do |key|
        series_data << tempodb_client.get_series(key)
      end

      series_data
    end

    def update_attribute(series_key, attribute, value)
      series = tempodb_client.get_series(series_key)
      series.attributes[attribute] = value
      tempodb_client.update_series(series)
    end

    def remove_attribute(series_key, attribute)
      series = tempodb_client.get_series(series_key)
      series.attributes = series.attributes.except(attribute)
      tempodb_client.update_series(series)
    end

    def add_tag(series_key, tag)
      series = tempodb_client.get_series(series_key)
      series.tags.push(tag)
      tempodb_client.update_series(series)
    end

    def remove_tag(series_key, tag)
      series = tempodb_client.get_series(series_key)
      series.tags.delete(tag)
      tempodb_client.update_series(series)
    end

    def for_series(name)
      raise('this method is deprecated')
      #new(name)
    end
  end

  attr_accessor :start, :stop, :data, :permalink, :series

  def initialize(data, series, start, stop)
    @series = series
    @data = data
    @start = start
    @stop = stop
    @permalink = permalink
  end

  def permalink
    params = {}
    params.merge!(series)
    params.merge!(start_time: start.to_f) if start
    params.merge!(stop_time: stop.to_f)   if stop
    Rails.application.routes.url_helpers.multiple_charts_path(params)
  end


  private

  def self.fix_times(time)
    return if time.blank?
    if time !~ /\d{4,}\-/ 
      Time.at(time.to_i)
    else
      Time.parse(time)
    end
  end

end
