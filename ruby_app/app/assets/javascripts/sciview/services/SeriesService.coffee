module = angular.module('sv.ui.services')

module.factory "SeriesService", [ "DS", (DS) ->
  DS.defineResource(
    name: 'series'
    endpoint: 'series'
    baseUrl: '/api/v1'
  )
]

module.factory "SeriesTagsService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/tags/:tagId"
]

module.factory "SeriesAttributesService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/attributes/:attributeId"
]


# sockets
angular.module('sciview').run([
  'mySocket'
  'SeriesService'
  (mySocket, SeriesService) ->
    mySocket.on('updateSeries', (series) ->
      console.log('updateSeries event -> ', series)
      SeriesService.inject(series)
    )
])
