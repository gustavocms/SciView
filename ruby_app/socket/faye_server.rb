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
      @rooms   = []
    end

    attr_reader :rooms, :clients

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
              p [:message, :subscribe, room.clients.length, message['id'], event.data]
            when 'update'
              room = broadcast(message['resource'],message['id'],ws,event.data)
              p [:message, :update, room.clients.length, message['id'], event.data]
            else
              p [:message, message, clients.length, event.data]
              clients.each {|ws| ws.send(event.data) }
          end

        end

        ws.on :close do |event|
          p [:close, clients.length, ws.object_id, event.code, event.reason]
          clients.delete(ws)
          rooms.each {|room| room.clients.delete(ws) }
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
    def room(resource, id)
      room = rooms.find{|a| a.resource == resource && a.id == id}
      if (room == nil)
        room = Room.new(resource, id)
        rooms << room
      end
      room.tap {|r| yield r }
    end

    def subscribe(resource, id, socket)
      room(resource,id) do |r|
        r.clients << socket
      end
    end

    def broadcast(resource, id, originSocket, data)
      room(resource,id) do |r|
        r.clients.each {|ws| ws.send(data) if ws != originSocket }
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
  end
end
