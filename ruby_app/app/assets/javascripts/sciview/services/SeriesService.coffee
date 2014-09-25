module = angular.module('sv.ui.services')

module.factory "SeriesService", [ "DS", (DS) ->
  DS.defineResource(
    name: 'series'
    endpoint: '/api/v1/series'
  )
]

module.factory "SeriesTagsService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/tags/:tagId"
]

module.factory "SeriesAttributesService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/attributes/:attributeId"
]