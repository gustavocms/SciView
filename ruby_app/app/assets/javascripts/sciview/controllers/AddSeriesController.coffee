module = angular.module("sv.ui.controllers")

module.controller "AddSeriesController", [
  "$scope"
  ($scope) ->
    $scope.is_adding = false
    $scope.placeholder = "Add Series"

    $scope.cancel = ->
      $scope.is_adding = false
      $scope.new_series_title = ""
      $scope.placeholder = "Add Series"

    $scope.selectSeries = (chart, series) ->
      console.log("select series")
      $scope.addSeries(chart, series)
      $scope.cancel()

    $scope.adding = (e, chart, series) ->
      $scope.is_adding = true
      if `e.keyCode == 13`
        $scope.addSeries(chart, series)
        $scope.cancel()

    $scope.focus = ->
      $scope.placeholder = "Search key, tag or attribute"

]
