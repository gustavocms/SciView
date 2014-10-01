# sockets
angular.module('sciview').run([
  'mySocket'
  'SeriesService'
  (mySocket, SeriesService) ->
    mySocket.on('updateSeries', (series) ->
      console.log('updateSeries event -> ', series)
      SeriesService.inject(series)
    )

    mySocket.on('updateObservations', (key) ->
      console.log('updateObservations', key)
      # TODO: NOW WHAT?
    )

])
