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
        socket_call(env)
      else
        app.call(env)
      end
    end

    private

    # Only allow these event names.
    # Anything else will be delegated to :_generic_message.
    SANITIZED_MESSAGE_NAMES = {
      "subscribe"                     => :_subscribe,
      "update"                        => :_update,
      "clearObservationSubscriptions" => :_clear_observation_subscriptions
    }

    def socket_call(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      ws.on :open do 
        clients << ws
        p [:open, clients.length, ws.object_id]
      end

      ws.on :message do |event|
        message = JSON.parse(event.data)['message']
        sym = SANITIZED_MESSAGE_NAMES.fetch(message['event'], :_generic_message)
        send(sym, message, ws, event)
      end

      ws.on :close do |event|
        p [:close, clients.length, ws.object_id, event.code, event.reason]
        clients.delete(ws)
        rooms.each {|_, room| room.delete(ws) }
      end

      # Return async Rack response
      ws.rack_response
    end

    def _subscribe(message, socket, *)
      subscribe(message['resource'], message['id'], socket)
    end

    def _update(message, socket, event)
      broadcast(message['resource'], message['id'], socket, event.data)
    end

    # To be run on a new viewState subscription (socket will only look at one at a time)
    # Could get slow with lots of rooms - should we also bind rooms to a socket attr?
    def _clear_observation_subscriptions(_, socket, *)
      rooms.select {|(resource, _), _| resource == "viewState" }.each_value do |room|
        p [:unsubscribe, "viewStateObservations", socket.object_id]
        room.delete(socket) 
      end
    end

    # NOTE: Is there any reason to do this? This leaves a hole for anyone
    # to spam all connected clients with whatever data they want.
    # Logged, but broadcast disabled for now.
    def _generic_message(message, socket, event)
      p ["BLOCKED", :message, message, clients.length, event.data]
      #clients.each {|ws| ws.send(event.data) }
    end

    def room_for(resource, id)
      rooms[[resource.to_s, id.to_s]].tap do |room|
        yield room if block_given?
      end
    end

    def subscribe(resource, id, socket)
      p [:subscribe, resource, id, socket.object_id]
      room_for(resource ,id) { |room| room << socket }
    end

    def broadcast(resource, id, origin_socket, data)
      p [:broadcast, resource, id, data]
      room_for(resource,id) do |room|
        room.each {|ws| ws.send(data) unless ws == origin_socket }
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

    def inspect
      "#<SciView::Room:#{object_id} [#{resource.inspect}, #{id.inspect}] clients=Set{ #{clients.count} clients }>"
    end

    def method_missing(name, *args, &block)
      clients.send(name, *args, &block)
    end
  end
end
