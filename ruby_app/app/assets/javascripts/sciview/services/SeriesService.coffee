app = angular.module('sv.ui.services')

app.factory('SeriesService', [
  '$resource'
  ($resource) ->
    $resource('/datasets/:id.json')
])


