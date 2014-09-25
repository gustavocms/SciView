module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "Observation"
  ($scope, Observation) ->
    $scope.observations = Observation.getObservations()
]
