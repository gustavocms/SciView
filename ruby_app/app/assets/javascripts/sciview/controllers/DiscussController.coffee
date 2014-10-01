module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "$stateParams"
  "Observation"
  "mySocket"
  ($scope, $stateParams, Observation, mySocket) ->

    $scope.observations = []
    $scope.observationsLoading.promise.then ->
      $scope.observations = $scope.$parent.observations

    # TODO: put this somewhere useful
    tap = (obj, func) ->
      func(obj)
      obj


    _observationPayload = (message, options = {}) ->
      tap { message: message }, (obj) ->
        (obj[attr] = options[attr] if options[attr]) for attr in ["chart_uuid", "observed_at"]

    $scope.newObservation = (message, options = {}) ->
      Observation.save({ dataSetId: $stateParams.dataSetId, observation: _observationPayload(message, options) })
        .$promise
        .then((data) -> $scope.observations.push(data))

    $scope.createObservation = (observation) ->
      Observation.create(observation)
        .then (data) ->
          $scope.observations.push(data)
          mySocket.emit('updateObservations', "viewState_#{data.view_state_id}")


    window.s = $scope
]
