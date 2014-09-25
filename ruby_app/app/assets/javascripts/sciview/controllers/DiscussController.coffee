module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "Observation"
  "$stateParams"
  ($scope, Observation, $stateParams) ->
    Observation.index($stateParams)
      .$promise
      .then((data) -> $scope.observations = data)
]
