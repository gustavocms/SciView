app = angular.module('sv.ui.services', ['ngResource'])
app.factory('ViewState', ['$resource',
  ($resource) -> return $resource('/api/v1/view_states/:viewStateId.json')
])
