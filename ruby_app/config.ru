# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require './socket/faye_server'

# Initialize faye sockets
use SciView::FayeServer

run Rails.application
