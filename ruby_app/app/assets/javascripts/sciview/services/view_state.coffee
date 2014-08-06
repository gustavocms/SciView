app = angular.module('sv.ui.services', ['ngResource'])
app.factory('ViewStateService', ['$resource',
  ($resource) ->
    return $resource('/api/v1/view_states/:viewStateId')
