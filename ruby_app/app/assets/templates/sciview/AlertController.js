module = angular.module("sv.ui.controllers")

module.controller "AlertController", [
  "$scope"
  "Sources"
  ($scope, Alerts) ->
  $scope.message = "New Alert";
]
