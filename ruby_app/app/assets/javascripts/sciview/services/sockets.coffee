module = angular.module('sv.ui.services')

#sockets configuration
module.factory('mySocket', (ngSocket) ->
  mySocket = ngSocket("ws://#{window.location.host}")

  mySocket.emit = (event, data) ->
    mySocket.send
      event: event
      data: data

  # receive messages
  mySocket.onEvent = (event, callBack, autoApply = false) ->
    mySocket.onMessage(
      (message) ->
        msg = JSON.parse(message.data).message
        if msg.event == event
          console.info(event + ' event -> ', msg.data)
          callBack(msg.data)
      autoApply: autoApply
    )

  mySocket.updateEvent = (resource, id, data) ->
    mySocket.send(
      event: "update"
      resource: resource
      id: id
      data: data)

  mySocket.onUpdateEvent = (resource, callBack, autoApply = false) ->
    mySocket.onMessage(
      (message) ->
        msg = JSON.parse(message.data).message
        if msg.event == "update" and msg.resource == resource
          console.info(resource + ' updateEvent -> ', msg.data)
          callBack(msg.data)
      autoApply: autoApply
    )

  mySocket.subscribe = (resource, id) ->
    mySocket.send(
      event: "subscribe"
      resource: resource
      id: id)

  mySocket.unsubscribe = (resource, id) ->
    mySocket.send(
      event: "unsubscribe"
      resource: resource
      id: id)

  mySocket
)

# Processing received messages:
#
#
module.run([
  'mySocket'
  'SeriesService'
  'Observation'
  (mySocket, SeriesService, Observation) ->

    mySocket.onUpdateEvent('series', (series) ->
      SeriesService.refresh(series.key)
    )

    _acceptable_observation_actions =
      find: Observation.find
      eject: Observation.eject

    mySocket.onUpdateEvent('viewStateObservations', (params) ->
      _acceptable_observation_actions[params.action](params.id)
    )

])
