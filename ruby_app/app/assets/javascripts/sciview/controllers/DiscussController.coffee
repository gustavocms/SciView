module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "Observation"
  ($scope, Observation) ->
    console.log($scope)
    window.p = $scope.$parent
    console.log($scope.$parent)
    console.log(p.current_data_set)

    Observation.index({ viewStateId: 43 })
      .$promise
      .then((data) -> $scope.observations = data)
]
