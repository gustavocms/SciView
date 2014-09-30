module = angular.module("sv.ui.controllers")

module.controller "MetadataController", [
  "$scope"
  "$q"
  "$timeout"
  "mySocket"
  "SeriesService"
  "SeriesTagsService"
  "SeriesAttributesService"
  ($scope, $q, $timeout, mySocket, SeriesService, SeriesTagsService, SeriesAttributesService) ->

    $scope.metaState =
      parameters:
        series_1: $scope.series.title #from parent controller
      showForm: false

    series_title = ->
      $scope.$parent.series.title

    # as the result query is an array, needed to process the promise to bind just the first result
    SeriesService.find(series_title())
    SeriesService.bindOne($scope, 'seriesData', series_title())

    #form model
    $scope.newMetadata =
      tag: ""
      attribute: ""
      value: ""

    $scope.saveMetaChannel = ->
      promises = []
      if $scope.newMetadata.tag.length > 0
        promise = saveNewTag()
        promises.push promise
      if $scope.newMetadata.attribute.length > 0
        promise = saveNewAttribute()
        promises.push promise

      #wait for all saving to be completed and then closes the form and cleanup the model.
      #defining finally as a string for IE compatibility (https://docs.angularjs.org/api/ng/service/$q)
      $q.all(promises)["finally"] ->
        $scope.metaState.showForm = false
        $scope.newMetadata.tag = ""
        $scope.newMetadata.attribute = ""
        $scope.newMetadata.value = ""
        return

      return

    withSocketEvent = (callback) ->
      ->
        callback()
        mySocket.emit('updateSeries', $scope.seriesData)
        return

    saveNewTag = ->
      tagData =
        tag: $scope.newMetadata.tag
      #change the object to be be persisted through DS repository
      $scope.seriesData.tags.push tagData.tag if $scope.seriesData.tags.indexOf(tagData.tag) is -1
      #ajax call and return promise of the saving call
      SeriesService.save($scope.seriesData.key)

    saveNewAttribute = ->
      attrData =
        attribute: $scope.newMetadata.attribute
        value: $scope.newMetadata.value
      #ajax call
      promise = SeriesAttributesService.save(
        seriesId: $scope.seriesData.key,
        attrData,
        #onSuccess promise function
        #update scope with new object and emit event for socket listeners
        withSocketEvent(-> $scope.seriesData.attributes[attrData.attribute] = attrData.value)
      ).$promise

      #return promise of the saving call
      promise

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
      deleteData =
        seriesId: $scope.seriesData.key
        tagId: tag
      # ajax call
      SeriesTagsService.delete(
        deleteData, {},
        # onSuccess promise function
        withSocketEvent( ->
          # update scope removing object and emit socket event
          $scope.seriesData.tags.splice($scope.seriesData.tags.indexOf(tag), 1)
          $scope.deleteMeta.remove_screen = false
          $scope.removeFlash()
        )
      )

    $scope.removeAttribute = (key) ->
      deleteData =
        seriesId: $scope.seriesData.key
        attributeId: key
      # ajax call
      SeriesAttributesService.delete(
        deleteData, {},
        # onSuccess promise function
        withSocketEvent(->
          # update scope removing object and emit socket event
          delete $scope.seriesData.attributes[key]
          $scope.deleteMeta.remove_screen = false
          $scope.removeFlash()
        )
      )
]
