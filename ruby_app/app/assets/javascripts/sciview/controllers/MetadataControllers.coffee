module = angular.module("sv.ui.controllers")

module.controller "MetadataController", [
  "$scope"
  "$timeout"
  "SeriesService"
  ($scope, $timeout, SeriesService) ->

    series_key = ->
      $scope.$parent.series.title

    # as the result query is an array, needed to process the promise to bind just the first result
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

      if $scope.newMetadata.attribute.length > 0
        attrData =
          attribute: $scope.newMetadata.attribute
          value: $scope.newMetadata.value
        #change the object to be persisted through DS repository
        $scope.seriesData.attributes[attrData.attribute] = attrData.value

      #ajax call then closes the form and cleanup the model.
      SeriesService.save($scope.seriesData.key).then((data)->
        $scope.newMetadata.showForm = false
        $scope.newMetadata.tag = ""
        $scope.newMetadata.attribute = ""
        $scope.newMetadata.value = ""
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
      # Clear selected tag
      $scope.deleteMeta.selected_tag = {}
      # Remove attr setting (for delete function)
      $scope.deleteMeta.is_attr = false
      # Show the remove screen
      $scope.deleteMeta.remove_screen = true
      # Set selected tag
      $scope.deleteMeta.selected_tag = tag
      return

    $scope.removeAttrView = (key, value) ->
      # Clear selected attr
      $scope.deleteMeta.selected_attr = {}
      # Set selected key
      $scope.deleteMeta.selected_key = key
      # Set attr setting to true (for delete selection)
      $scope.deleteMeta.is_attr = true
      # Show remove screen
      $scope.deleteMeta.remove_screen = true
      # Build attribute string
      $scope.deleteMeta.selected_attr = key + ": " + value
      return

    $scope.hideRemoveView = ->
      # Hide remove screen
      $scope.deleteMeta.remove_screen = false
      return

    $scope.removeFlash = ->
      # Show alert
      $scope.deleteMeta.remove_flash = true
      # Remove alert
      $timeout (->
        $scope.deleteMeta.remove_flash = false
        return
      ), 1500
      return

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
      delete $scope.seriesData.attributes[key]

      #ajax call then closes the form and cleanup the model.
      SeriesService.save($scope.seriesData.key).then((data)->
        $scope.deleteMeta.remove_screen = false
        $scope.removeFlash()
      )
]
