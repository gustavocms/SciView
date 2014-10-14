module = angular.module('sv.ui.services')

module.factory "SeriesService", [ "DS", "mySocket", (DS, mySocket) ->
  DS.defineResource(
    name:        'series'
    endpoint:    'series'
    baseUrl:     '/api/v1'
    idAttribute: 'key'
    afterUpdate: (resourceName, attrs, cb) ->
      mySocket.updateEvent(resourceName, attrs.key, { key: attrs.key })
      # proceed with the lifecycle
      cb(null, attrs)
    afterInject: (resourceName, attrs) ->
      mySocket.subscribe(resourceName, attrs.key)
  )
]
