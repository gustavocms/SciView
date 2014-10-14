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
  ($scope, $state, $stateParams, $timeout, $q, ViewState, SeriesService, Observation, mySocket) ->

    $scope.viewStateLoading = $q.defer()
    # waits for the parent loading to finish
    $scope.deferredDatasetsLoading.promise.then ->
      filteredDS = $scope.$parent.data_sets.filter (ds) ->
        ds.id.toString() == $stateParams.dataSetId
      $scope._setViewState(filteredDS[0])

      # used to manage changes that may be reverted
      $scope.tempViewState =
        title: $scope.viewState.title


    # OBSERVATION STUFF
    # 
    #
    openObservationsPanel = -> $state.go('data-sets.single.discuss')

    $scope.setObservationsOnViewState = ->
      try
        $scope.viewState.observations($scope.observations)

    $scope.observationsLoading = $q.defer()
    obs_params = view_state_id: $stateParams.dataSetId
    Observation.findAll(obs_params)
    Observation.bindAll($scope, 'observations', obs_params, ->
      $scope.setObservationsOnViewState()
    )

    _newObservation = (params = {}) ->
      $scope.obs_saving     = false
      $scope.newObservation =
        message: ''
        view_state_id: $stateParams.dataSetId
      $scope.newObservation[key] = value for key, value of params
      try
        $scope.$digest()

    $scope.viewStateLoading.promise.then ->
      $scope.setObservationsOnViewState()
      $scope.viewState.registerCallback('_observationCallback', _newObservation, (ui_chart, cb) ->
        (params = {}) ->
          openObservationsPanel()
          params.chart_uuid = ui_chart.uuid
          cb(params)
      )

    _newObservation()
    $scope._newObservation = _newObservation # must be made available to DiscussController
    #
    #
    # END OF OBSERVATION STUFF

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

    $scope.registerSocketWatchers = -> # noOp pending fix
      mySocket.emit('resetSubscriptions')
      mySocket.subscribe('viewStateObservations', $scope.viewState.id)
      for seriesName in $scope.viewState.seriesKeys()
        mySocket.subscribe('series', seriesName)


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
