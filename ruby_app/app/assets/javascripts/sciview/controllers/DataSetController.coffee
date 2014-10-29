module = angular.module("sv.ui.controllers")

module.controller('DataSetController', [
  '$scope'
  '$state'
  '$stateParams'
  '$timeout'
  '$q'
  'ViewState'
  'SeriesService'
  'Observation'
  'mySocket'
  'data_set'
  ($scope, $state, $stateParams, $timeout, $q, ViewState, SeriesService, Observation, mySocket, data_set) ->

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
#      $scope.viewStateLoading.resolve()
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
        $scope.viewState = SciView.Models.ViewState.deserialize(data)
    )

    # used to manage changes that may be reverted
    $scope.tempViewState =
      title: $scope.viewState.title

#   as seen here:
#   http://stackoverflow.com/questions/16947771/how-do-i-ignore-the-initial-load-when-watching-model-changes-in-angularjs
    initializing = true
    afterInitialization = (callback) ->
      if initializing
        $timeout(()-> initializing = false)
      else
        callback()

    $scope.$watch(
      'viewState.serialize()'
      () -> afterInitialization($scope.saveDataset)
      true
    )

    $scope.joinAttributes = (attributes) ->
      attributesList = ''
      angular.forEach(attributes, (value, key) ->
        attributesList += key + ':' + value + ', '
      )
      return attributesList

#    TODO: implement filtering on the serverside
    $scope.querySeriesList = (typed) ->

      matcher = RegExp(typed, 'i')
      filteredSeries = []

    # full list of series
      SeriesService.findAll().then (data) ->
        $scope.seriesList = data

        # search seriesList for matching items
        angular.forEach($scope.seriesList, (item, i) ->
          seriesTerms = item.key + '|' + item.tags.join('|') + $scope.joinAttributes(item.attributes)

          if matcher.test(seriesTerms)
            # used to control exhibition at autocomplete
            item.hasTags = item.tags.length > 0
            item.hasAttributes = $scope.joinAttributes(item.attributes).length > 0

            # add item to autocomplete list
            filteredSeries.push(item)
        )

        return filteredSeries

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "retracted" then "expanded" else "retracted")
])
