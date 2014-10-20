YAML.load(File.read(File.join(Rails.root, *%w[config influx_db.yml]))).tap do |config|
  INFLUX_DB_NAME = config[Rails.env]["name"]
end
