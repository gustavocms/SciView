module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "Observations"
  ($scope, Observations) ->
    $scope.observations = Observations.getObservations()
]