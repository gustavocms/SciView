angular.module('sv.charts.annotations.services', ['ngResource'])
  .factory('AnnotationsService', ['$resource',
    ($resource) ->
      $resource('/datasets/:seriesId/annotations/:annotationId')
  ])
