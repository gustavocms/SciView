require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

module Sciview
  class FayeServer
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app)
      @app     = app
      @clients = []
      @rooms = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          @clients << ws
          p [:open, @clients.length, ws.object_id]
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
              p [:message, message, @clients.length, event.data]
              @clients.each {|ws| ws.send(event.data) }
          end

        end

        ws.on :close do |event|
          p [:close, @clients.length, ws.object_id, event.code, event.reason]
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
    def getRoom(resource, id)
      room = @rooms.find{|a| a.resource == resource && a.id == id}
      if (room == nil)
        room = Room.new(resource, id)
        @rooms << room
      end
      return room
    end

    def subscribe(resource, id, socket)
      room = getRoom(resource,id)
      room.clients << socket if !room.clients.include?(socket)
      return room
    end

    def broadcast(resource, id, originSocket, data)
      room = getRoom(resource,id)
      room.clients.each {|ws| ws.send(data) if ws != originSocket }
      return room
    end
  end

  class Room
    def resource
      @resource
    end
    def id
      @id
    end
    def clients
      @clients
    end
    def initialize(resource, id)
      @resource = resource
      @id = id
      @clients = []
    end
  end
end
