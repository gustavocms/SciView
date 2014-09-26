module = angular.module("sv.ui.controllers")

module.controller "DiscussController", [
  "$scope"
  "$stateParams"
  ($scope, $stateParams) ->
    $scope.observations = $scope.$parent.observations
]
