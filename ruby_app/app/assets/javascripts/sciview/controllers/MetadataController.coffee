module = angular.module("sv.ui.controllers")

module.controller "MetadataController", [
  "$scope"
  "$timeout"
  "SeriesService"
  ($scope, $timeout, SeriesService) ->

    series_key = ->
      $scope.$parent.series.title

    SeriesService.refresh(series_key()) # This should only run if necessary (ie, already in the data store)

    SeriesService.find(series_key())
    SeriesService.bindOne($scope, 'seriesData', series_key())

    #newMetadata form model
    $scope.newMetadata =
      tag: ""
      attribute: ""
      value: ""
      showForm: false

    $scope.saveMetaChannel = ->
      if $scope.newMetadata.tag.length > 0
        tagData =
          tag: $scope.newMetadata.tag
        #change the object to be persisted through DS repository
        $scope.seriesData.tags.push tagData.tag if $scope.seriesData.tags.indexOf(tagData.tag) is -1
      else if $scope.newMetadata.attribute.length > 0
        attrData =
          key: $scope.newMetadata.attribute
          value: $scope.newMetadata.value
        # If the 'key' already belongs to another attribute, update it.
        # Otherwise push a new one.
        existing = $scope.seriesData.attributes.filter((e) -> e.key is attrData.key)
        if existing.length > 0
          existing[0].value = attrData.value
        else
          $scope.seriesData.attributes.push(attrData)

      #ajax call then closes the form and cleanup the model.
      SeriesService.save($scope.seriesData.key).then((data)->
        $scope.newMetadata.showForm = false
        $scope.newMetadata.tag = ""
        $scope.newMetadata.attribute = ""
        $scope.newMetadata.value = "empty..."
      )

    #deleteMeta form model
    $scope.deleteMeta =
      selected_tag: {}
      selected_attr: {}
      selected_key: {}
      is_attr: false
      remove_screen: false
      remove_flash: false

    $scope.removeTagView = (tag) ->
      $scope.deleteMeta.selected_tag  = {}    # Clear selected tag
      $scope.deleteMeta.is_attr       = false # Remove attr setting (for delete function)
      $scope.deleteMeta.remove_screen = true  # Show the remove screen
      $scope.deleteMeta.selected_tag  = tag   # Set selected tag

    $scope.removeAttrView = (attribute) ->
      key   = attribute.key
      value = attribute.value
      $scope.deleteMeta.selected_attr = {}                 # Clear selected attr
      $scope.deleteMeta.selected_key  = key                # Set selected key
      $scope.deleteMeta.is_attr       = true               # Set attr setting to true (for delete selection)
      $scope.deleteMeta.remove_screen = true               # Show remove screen
      $scope.deleteMeta.selected_attr = "#{key}: #{value}" # Build attribute string

    $scope.hideRemoveView = ->
      $scope.deleteMeta.remove_screen = false # Hide remove screen

    $scope.removeFlash = ->
      $scope.deleteMeta.remove_flash = true # Show alert
      $timeout (-> $scope.deleteMeta.remove_flash = false), 1500 # Remove alert

    $scope.removeTag = (tag) ->
      #change the object to be persisted through DS repository
      $scope.seriesData.tags.splice($scope.seriesData.tags.indexOf(tag), 1)

      #ajax call then closes the form and cleanup the model.
      SeriesService.save($scope.seriesData.key).then((data)->
        $scope.deleteMeta.remove_screen = false
        $scope.removeFlash()
      )

    $scope.removeAttribute = (key) ->
      #change the object to be persisted through DS repository
      $scope.seriesData.attributes = $scope.seriesData.attributes.filter((e) -> e.key isnt key)

      #ajax call then closes the form and cleanup the model.
      SeriesService.save($scope.seriesData.key).then((data)->
        $scope.deleteMeta.remove_screen = false
        $scope.removeFlash()
      )
]
