module = angular.module('sv.ui.services')

module.factory "MetadataService", [ "DS", (DS) ->
  DS.defineResource(
    name: 'metadata'
    endpoint: '/api/v1/datasets/metadata'
    idAttribute: 'key',
  )
]
module.factory "SeriesTagsService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/tags/:tagId"
]
module.factory "SeriesAttributesService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/attributes/:attributeId"
]
