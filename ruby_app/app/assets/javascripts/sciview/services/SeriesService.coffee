module = angular.module('sv.ui.services')

module.factory('SeriesService', [
  '$resource'
  ($resource) ->
    $resource('/datasets/:id.json')
])


