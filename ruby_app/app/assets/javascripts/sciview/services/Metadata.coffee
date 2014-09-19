module = angular.module('sv.ui.services')

module.factory "MetadataService", [ "$resource", ($resource) ->
  $resource "/datasets/metadata"
]
module.factory "SeriesTagsService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/tags/:tagId"
]
module.factory "SeriesAttributesService", [ "$resource", ($resource) ->
  $resource "/datasets/:seriesId/attributes/:attributeId"
]
