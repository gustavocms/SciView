module = angular.module("sv.ui.controllers")

module.controller "ToolController", [
  "$scope"
  ($scope) ->
    $scope.channel =
      title: "oil-pressure_3a"
      category: "thrusters"
      value: "321"
      unit: "psi"

    $scope.data_set =
      time: "00:20:38:12"
      unit: "seconds"
]
