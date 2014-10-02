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
    Observation.bindAll($scope, 'observations', { view_state_id: $stateParams.dataSetId })

    _observationPayload = (message, options = {}) ->
      tap { message: message }, (obj) ->
        (obj[attr] = options[attr] if options[attr]) for attr in ["chart_uuid", "observed_at"]

    #$scope.newObservation = (message, options = {}) ->
    #Observation.save({ dataSetId: $stateParams.dataSetId, observation: _observationPayload(message, options) })
    #.$promise
    #.then((data) -> $scope.observations.push(data))

    _newObservation = ->
      $scope.observationFormPlaceholder = "New message..."
      $scope.saving = false
      $scope.newObservation =
        message: ''
        view_state_id: $stateParams.dataSetId


    _newObservation()

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



    window.s = $scope
]
