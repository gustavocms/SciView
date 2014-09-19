app = angular.module("sciview")

app.controller "DiscussController", [
  "$scope"
  "Observations"
  ($scope, Observations) ->
    $scope.observations = Observations.getObservations()
]