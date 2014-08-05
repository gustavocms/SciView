web: bundle exec puma -C ruby_app/config/puma.rb -p $PORT
redis: redis-server
worker: bundle exec sidekiq -c 5 -v