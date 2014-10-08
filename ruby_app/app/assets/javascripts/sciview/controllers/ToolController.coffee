module = angular.module("sv.ui.controllers")

module.controller "ToolController", [
  "$scope"
  "$rootScope"
  ($scope, $rootScope) ->

    $scope.data_set =
      time: "00:20:38:12"
      unit: "seconds"
]