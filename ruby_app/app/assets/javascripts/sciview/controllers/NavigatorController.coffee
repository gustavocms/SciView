app = angular.module("sciview")

app.controller "NavigatorController", [
  "$scope"
  "Sources"
  ($scope, Sources) ->
    $scope.sources = Sources.getDataSources()
    $scope.navigator = search_query: ""
]
