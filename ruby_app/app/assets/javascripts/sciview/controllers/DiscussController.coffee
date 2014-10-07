module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "$stateParams"
  "Observation"
  "mySocket"
  "timeAgoFilter"
  ($scope, $stateParams, Observation, mySocket, timeAgoFilter) ->

    # TODO: put this somewhere useful
    tap = (obj, func) ->
      func(obj)
      obj


    Observation.findAll({ view_state_id: $stateParams.dataSetId })
    #$scope.datasetLoading.promise.then ->
    Observation.bindAll($scope, 'observations', { view_state_id: $stateParams.dataSetId }, (data) ->
      try
        $scope.$parent.viewState.observations($scope.observations)
    )

    # sets the newObservation model and associated state variables

    $scope.chartUuids = ->
      try
        # TODO: need to be able to update this variable when the parent scope changes
        @_chartUuids or= $scope.$parent.viewState.chartUuids()
      catch
        []

    $scope.observationFormPlaceholder = "New message..."

    _newObservation = (params = {}) ->
      $scope.saving = false
      $scope.newObservation =
        message: ''
        view_state_id: $stateParams.dataSetId
      $scope.newObservation[key] = value for key, value of params
      try
        $scope.$digest()

    $scope.datasetLoading.promise.then ->
      $scope.$parent.viewState.observationCallback(_newObservation)

    _newObservation()


    $scope.observationLabel = (obs) ->
      if obs.chart_uuid
        $scope.chartUuids()[obs.chart_uuid]
      else
        $scope.$parent.viewState.name

    emitUpdateObservations = (params = {}) ->
      mySocket.emit('updateObservations', "viewState_#{$stateParams.dataSetId}", params)

    $scope.createObservation = (observation) ->
      $scope.saving = true
      Observation.create(observation).then (data) ->
        emitUpdateObservations({ id: data.id, action: 'find' })
        _newObservation()

    $scope.deleteObservation = (observation) ->
      Observation.destroy(observation.id).then (data) ->
        console.log('destroy', data)
      emitUpdateObservations({ id: observation.id, action: 'eject' })

]
