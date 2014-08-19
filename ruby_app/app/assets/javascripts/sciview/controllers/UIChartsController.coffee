app = angular.module('sciview')

app.controller("UIChartController", [
  '$scope'
  '$state'
  '$element'
  ($scope, $state, $element) ->
    $scope.addSeries = (ui_chart, series_title, group = null) ->
      if group
        # TODO: do something with the group
      else
        ui_chart.addSeries(series_title)

    $scope.chart.initializeChart($element.find('.batch__chart')[0]) # TODO: any way not to need $element in the controller?
    $scope.chart.refresh()
])
