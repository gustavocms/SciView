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


    # Observations now loaded by DataSetController
    #Observation.findAll({ view_state_id: $stateParams.dataSetId })
    #$scope.viewStateLoading.promise.then ->
    #Observation.bindAll($scope, 'observations', { view_state_id: $stateParams.dataSetId }, (data) ->
    #try
    #$scope.$parent.viewState.observations($scope.observations)
    #)
    #


    window.obs = $scope

    # sets the newObservation model and associated state variables

    $scope.chartUuids = ->
      try
        # TODO: need to be able to update this variable when the parent scope changes
        @_chartUuids or= $scope.viewState.chartUuids()
      catch
        []

    $scope.observationFormPlaceholder = "New message..."

    $scope.observationLabel = (obs) ->
      if obs.chart_uuid
        $scope.chartUuids()[obs.chart_uuid]
      else
        $scope.$parent.viewState.name

    emitUpdateObservations = (params = {}) ->
      mySocket.emit('updateObservations', "viewState_#{$stateParams.dataSetId}", params)

    $scope.createObservation = (observation) ->
      $scope.$parent.obs_saving = true
      Observation.create(observation).then (data) ->
        emitUpdateObservations({ id: data.id, action: 'find' })
        $scope.$parent._newObservation()

    $scope.deleteObservation = (observation) ->
      Observation.destroy(observation.id).then (data) ->
        console.log('destroy', data)
      emitUpdateObservations({ id: observation.id, action: 'eject' })

]
