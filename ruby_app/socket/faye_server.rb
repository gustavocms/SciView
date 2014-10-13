require 'faye/websocket'
require 'json'
require 'set'

module Sciview
  class FayeServer
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app)
      @app     = app
      @clients = []
      @rooms   = Hash.new {|hash, key| hash[key] = Room.new(*Array(key)) }
    end

    attr_reader :rooms, :clients, :app

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          clients << ws
          p [:open, clients.length, ws.object_id]
        end

        ws.on :message do |event|
          message = JSON.parse(event.data)['message']
          case message['event']
          when 'subscribe'
            room = subscribe(message['resource'],message['id'],ws)
            p [:message, :subscribe, room.size, message['id'], event.data]
          when 'update'
            room = broadcast(message['resource'],message['id'],ws,event.data)
            p [:message, :update, room.size, message['id'], event.data]
          else
            p [:message, message, clients.length, event.data]
            clients.each {|ws| ws.send(event.data) }
          end
        end

        ws.on :close do |event|
          p [:close, clients.length, ws.object_id, event.code, event.reason]
          clients.delete(ws)
          rooms.each {|_, room| room.delete(ws) }
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        app.call(env)
      end
    end

    private

    def room_for(resource, id)
      rooms[[resource, id]].tap do |room|
        yield room if block_given?
      end
    end

    def subscribe(resource, id, socket)
      room_for(resource ,id) do |room|
        room << socket
      end
    end

    def broadcast(resource, id, originSocket, data)
      room_for(resource,id) do |room|
        room.each {|ws| ws.send(data) if ws != originSocket }
      end
    end
  end

  class Room
    attr_reader :resource, :id, :clients

    def initialize(resource, id)
      @resource = resource
      @id       = id
      @clients  = Set.new
    end

    def method_missing(name, *args, &block)
      clients.send(name, *args, &block)
    end
  end
end
