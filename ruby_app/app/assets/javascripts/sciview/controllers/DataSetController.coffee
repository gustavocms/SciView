module = angular.module("sv.ui.controllers")

module.controller('DataSetController', [
  '$scope'
  '$state'
  '$stateParams'
  '$timeout'
  'ViewState'
  'mySocket'
  'data_set'
  ($scope, $state, $stateParams, $timeout, ViewState, mySocket, data_set) ->

    $scope.tooltip =
      time: "00:00:00:00"
      unit: "seconds"

    $scope.obsTime = "000"

    $scope.states =
      is_renaming: false
      is_discussing: false

    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = ->
      @viewState.addChart()

    $scope.logDataset = ->
      console.log(@viewState)
      console.log(angular.toJson(@viewState.serialize()))

    $scope.saveDataset = ->
      ViewState.update(
        $scope.viewState.id,
        $scope.viewState.serialize()
      )
      console.log('saving')

    $scope.deleteDataset = ->
      viewStateId = $scope.viewState.id
      ViewState.destroy(viewStateId)
        .then(->
          $scope.$parent.data_sets = $scope.$parent.data_sets.filter((ds) -> ds.id isnt viewStateId)
          $scope.$state.go('data-sets')
        )

    $scope._setViewState = (viewState) ->
      $scope.viewState = viewState
      $scope.registerSocketWatchers()

      viewState.registerCallback("_cursorCallback", (data) ->
        $scope.obsTime = data
        $scope.$digest()
      )

    $scope.saveRenaming = ->
      $scope.viewState.title = $scope.tempViewState.title
      $scope.states.is_renaming = false

    $scope.cancelRenaming = ->
      $scope.tempViewState.title = $scope.viewState.title
      $scope.states.is_renaming = false

    $scope.registerSocketWatchers = -> # noOp pending fix
      mySocket.emit('resetSubscriptions')
      mySocket.subscribe('viewState', $scope.viewState.id)
      mySocket.subscribe('viewStateObservations', $scope.viewState.id)
      for seriesName in $scope.viewState.seriesKeys()
        mySocket.subscribe('series', seriesName)

    $scope._setViewState(data_set)

    $scope.$watch(
      ->
        ViewState.lastModified $stateParams.dataSetId
      ->
        data = ViewState.get($stateParams.dataSetId)
        $scope._setViewState (SciView.Models.ViewState.deserialize(data))
    )

    # used to manage changes that may be reverted
    $scope.tempViewState =
      title: $scope.viewState.title

    $scope.$watch(
      'viewState.serialize()'
      () ->
        # before saving, confirm that the model is distinct from the cache, to restrict saving to user actions
        cachedData = ViewState.get($stateParams.dataSetId)
        cachedData = SciView.Models.ViewState.deserialize(cachedData)
        cachedData = angular.toJson(cachedData.serialize())
        viewData = angular.toJson($scope.viewState.serialize())
        $scope.saveDataset() if viewData != cachedData
      true
    )

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "retracted" then "expanded" else "retracted")
])
