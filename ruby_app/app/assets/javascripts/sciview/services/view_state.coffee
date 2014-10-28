module = angular.module('sv.ui.services')

module.factory "ViewState", [ "DS", "mySocket", (DS, mySocket) ->
  DS.defineResource(
    name:        'viewState'
    endpoint:    'view_states'
    baseUrl:     '/api/v1'
  )
]
