require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'
require 'set'

module Sciview
  class FayeServer
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app)
      @app     = app
      @clients = []
      @rooms   = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          @clients << ws
          log :open, @clients.length, ws.object_id
        end

        ws.on :message do |event|
          message = JSON.parse(event.data)['message']
          case message['event']
          when 'subscribe'
            room = subscribe(message['resource'],message['id'],ws)
            log  :message, :subscribe, room.clients.length, message['id'], event.data
          when 'update'
            room = broadcast(message['resource'],message['id'],ws,event.data)
            log :message, :update, room.clients.length, message['id'], event.data
          else
            log :message, message, @clients.length, event.data
            @clients.each {|ws| ws.send(event.data) }
          end

        end

        ws.on :close do |event|
          log :close, "n clients #{@clients.length}", "ws.object_id: #{ws.object_id}", "event.code #{event.code}", "event.reason #{event.reason}"
          @clients.delete(ws)
          @rooms.each {|room| room.clients.delete(ws) }
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

    def room(resource, id)
      room = @rooms.find{|a| a.resource == resource && a.id == id}
      if (room == nil)
        room = Room.new(resource, id)
        @rooms << room
      end
      return room
    end

    def subscribe(resource, id, socket)
      room(resource,id).tap {|r| r << socket }
    end

    def broadcast(resource, id, origin_socket, data)
      room(resource, id).tap do |r|
        room.each {|ws| ws.send(data) unless ws == origin_socket }
      end
    end
  end

  require 'set'

  class Room

    attr_reader :resource, :id, :clients

    def initialize(resource, id, *clients)
      @resource = resource
      @id       = id
      @clients  = Set.new(Array(clients))
    end

    # delegate methods to set
    def method_missing(name, *args, &block)
      clients.send(name, *args, &block)
    end
  end
end
