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
  'DS'
  'mySocket'
  ($scope, $state, $stateParams, $timeout, $q, ViewState, SeriesService, Observation, DS, mySocket) ->

    $scope.viewStateLoading = $q.defer()
    # waits for the parent loading to finish
    $scope.deferredDatasetsLoading.promise.then ->
      filteredDS = $scope.$parent.data_sets.filter (ds) ->
        ds.id.toString() == $stateParams.dataSetId
      $scope._setViewState(filteredDS[0])

      # used to manage changes that may be reverted
      $scope.tempViewState =
        title: $scope.viewState.title

    $scope.observationsLoading = $q.defer()
    obs_params = view_state_id: $stateParams.dataSetId
    Observation.findAll(obs_params)
    Observation.bindAll($scope, 'observations', obs_params, ->
      console.log("Observation bindAll callback")
      try
        $scope.$parent.viewState.observations($scope.observations)
    )

    window.dss = $scope

    $scope.openObservations = -> $state.go('data-sets.single.discuss')


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

    $scope.dblClickEvent = (data) ->
      @observationCallback(data)

    $scope.observationCallback = (data) ->
      console.info('observationCallback')

    $scope.saveDataset = ->
      ViewState.update(
        { id: $scope.viewState.id },
        $scope.viewState.serialize()
      )
      console.log('saving')

    $scope.deleteDataset = ->
      viewStateId = $scope.viewState.id
      ViewState.delete({ id: viewStateId })
        .$promise
        .then(->
          $scope.$parent.data_sets = $scope.$parent.data_sets.filter((ds) -> ds.id isnt viewStateId)
          $scope.$state.go('data-sets')
        )

    $scope._setViewState = (viewState) ->
      $scope.viewState = viewState
      $scope.viewStateLoading.resolve()
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

    $scope.registerSocketWatchers = ->
      mySocket.emit('resetWatchers')
      mySocket.emit('listenTo', "viewState_#{$scope.viewState.id}")
      for seriesName in $scope.viewState.seriesKeys()
        mySocket.emit('listenTo', seriesName)

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

    # full list of series
    SeriesService.findAll()
    SeriesService.bindAll($scope, 'seriesList', {})

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

#     search seriesList for matching items
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
