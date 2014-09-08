# require "tdms/version"

dir_path = File.expand_path(File.dirname(__FILE__))
require_path = "#{dir_path}/tdms/*.rb"
Dir.glob(require_path).each do |file|
  require file
end