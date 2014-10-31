begin
  YAML.load(File.read(File.join(Rails.root, *%w[config influx_db.yml]))).tap do |config|
    INFLUX_DB_NAME = config[Rails.env]["name"]
    unless InfluxDB::Client.new.get_database_list.any? {|db| db["name"] == INFLUX_DB_NAME }
      InfluxDB::Client.new.create_database(INFLUX_DB_NAME)
    end
  end
rescue
  logger.warn "InfluxDB could not be configured."
end
