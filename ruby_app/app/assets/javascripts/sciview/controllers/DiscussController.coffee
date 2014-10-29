module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "$stateParams"
  "Observation"
  "mySocket"
  ($scope, $stateParams, Observation, mySocket) ->

    # TODO: put this somewhere useful
    tap = (obj, func) ->
      func(obj)
      obj

    Observation.bindAll($scope, 'observations', view_state_id: $stateParams.dataSetId)

    # sets the newObservation model and associated state variables
    $scope.obs_saving     = false
    $scope.newObservation =
      message: ''
      view_state_id: $stateParams.dataSetId
    $scope.newObservation[key] = value for key, value of $stateParams
#    try
#      $scope.$digest()


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
      mySocket.updateEvent('viewStateObservations', $stateParams.dataSetId, params)
      #mySocket.emit('updateObservations', "viewState_#{$stateParams.dataSetId}", params)

    $scope.createObservation = (observation) ->
      $scope.obs_saving = true
      Observation.create(observation).then (data) ->
        emitUpdateObservations({ id: data.id, action: 'find' })
        $scope.$parent._newObservation()

    $scope.deleteObservation = (observation) ->
      Observation.destroy(observation.id).then (data) ->
      emitUpdateObservations({ id: observation.id, action: 'eject' })

]
