module = angular.module("sv.ui.controllers")

module.controller "NavigatorController", [
  "$scope"
  "Sources"
  ($scope, Sources) ->
    $scope.sources = Sources.getDataSources()
    $scope.navigator = search_query: ""
]
