# Processing received messages:
#
#
angular.module('sv.ui.services').run([
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
