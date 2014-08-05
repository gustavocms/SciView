workers Integer(ENV['PUMA_WORKERS'] || 1)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 16)

directory 'ruby_app' unless Dir.getwd == 'ruby_app'

preload_app!

rackup DefaultRackup
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    (ActiveRecord::Base.configurations[Rails.env] ||
    Rails.application.config.database_configuration[Rails.env]).tap do |config|
      config['pool'] = ENV['MAX_THREADS'] || 16
      ActiveRecord::Base.establish_connection(config)
    end

    if defined?(Sidekiq)
      # TODO: configure Sidekiq here...
    end
  end
end
