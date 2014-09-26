module = angular.module("sv.ui.controllers")

module.controller("UIChartController", [
  '$scope'
  '$element'
  '$window'
  ($scope, $element, $window) ->
    
    $scope.is_adding = false

    console.log($scope)

    $scope.addSeriesWindow = ->
      $scope.is_adding = true

    $scope.cancel = ->
      $scope.is_adding = false
      $scope.new_series_title = ""

    $scope.addSeriesRemoveWindow = (item, model, label, chart) ->
      $scope.addSeries(chart, item.key)
      # TODO: error state/callback is save fails 
      $scope.is_adding = false
      $scope.new_series_title = ""

    $scope.addSeries = (ui_chart, series_title, group = null) ->
      console.log(ui_chart, $scope.chart, series_title)
      if group
        # TODO: do something with the group
      else
        ui_chart.addSeries(series_title)

    $scope.chart.initializeChart($element.find('.batch__chart')[0]) # TODO: any way not to need $element in the controller?
    $scope.chart.refresh()

    $scope.chartResize = () ->
      $scope.chart.chart.redraw()

#   binds the resize event
    angular.element($window).on('resize', $scope.chartResize)

#   unbinds the resize event
    $scope.$on("$destroy", () ->
      angular.element($window).off('resize', $scope.chartResize);
    )
])
