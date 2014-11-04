module = angular.module('sv.ui.services')

module.factory "ViewState", [ "DS", "mySocket", (DS, mySocket) ->
  DS.defineResource(
    name:        'viewState'
    endpoint:    'view_states'
    baseUrl:     '/api/v1'
    afterUpdate: (resourceName, attrs, cb) ->
      mySocket.updateEvent(resourceName, attrs.id)
      # proceed with the lifecycle
      cb(null, attrs)
#    afterInject: (resourceName, attrs) ->
#      mySocket.subscribe(resourceName, attrs.id)
  )
]
