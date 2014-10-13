require 'faye/websocket'
require 'json'
require 'erb'

module ChatDemo
  class ChatBackend
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app)
      @app     = app
      @clients = []

      # uri = URI.parse(ENV["REDISCLOUD_URL"])
      # @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      # Thread.new do
      #   redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      #   redis_sub.subscribe(CHANNEL) do |on|
      #     on.message do |channel, msg|
      #       p [:redis_broadcast, @clients.length, channel, msg]
      #       @clients.each {|ws| ws.send(msg) }
      #     end
      #   end
      # end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, { ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          @clients << ws
          log :open, @clients.length, ws.object_id
        end

        ws.on :subscribe do |event|
          log :subscribe, ws.object_id, event.data
        end

        ws.on :message do |event|
          log :message, @clients.length, event.data
          # @redis.publish(CHANNEL, sanitize(event.data))
          @clients.each {|ws| ws.send(event.data) }
        end

        ws.on :close do |event|
          log :close, @clients.length, ws.object_id, event.code, event.reason
          @clients.delete(ws)
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private

    def log(*args)
      puts "SOCKET :: "
      args.each(&method(:puts))
    end

    def sanitize(message)
      json = JSON.parse(message)
      json.each {|key, value| json[key] = ERB::Util.html_escape(value) }
      JSON.generate(json)
    end
  end
end
