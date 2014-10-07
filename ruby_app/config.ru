# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require './socket/chat_backend'

# Initialize faye sockets
use ChatDemo::ChatBackend

run Rails.application
