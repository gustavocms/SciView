module = angular.module("sv.ui.controllers")

module.controller "AddSeriesController", [
  "$scope"
  ($scope) ->

    $scope.placeholder = "Search key, tag or attribute"

    $scope.selectSeries = (chart, series) ->
      console.log("select series")
      $scope.addSeries(chart, series)
      $scope.cancel()

    $scope.adding = (e, chart, series) ->
      $scope.is_adding = true
      if `e.keyCode == 13`
        $scope.addSeries(chart, series)
        $scope.cancel()
]
