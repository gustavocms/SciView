if Rails.env == '_development'
  require 'rack-mini-profiler'
  puts "rack-mini-profiler"
  Rack::MiniProfilerRails.initialize!(Rails.application)
end