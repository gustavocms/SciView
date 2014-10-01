# Processing received messages:
#
angular.module('sciview').run([
  'mySocket'
  'SeriesService'
  'Observation'
  (mySocket, SeriesService, Observation) ->
    mySocket.on('updateSeries', (series) ->
      console.log('updateSeries event -> ', series)
      SeriesService.inject(series)
    )

    acceptable_actions =
      find: Observation.find
      eject: Observation.eject

    mySocket.on('updateObservations', (key, params) ->
      console.log('updateObservations', key, params)
      acceptable_actions[params.action](params.id)
      #Observation.findAll({ view_state_id: key.split(/_/)[0] })
    )

    window.Observation = Observation

])
