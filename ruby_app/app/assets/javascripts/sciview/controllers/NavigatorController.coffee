module = angular.module("sv.ui.controllers")

module.controller "NavigatorController", [
  "$scope"
  "data_sets"
  ($scope, data_sets) ->
    $scope.navigator = search_query: ""

    $scope.data_sets = data_sets
    console.log($scope.data_sets)
]
