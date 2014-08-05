app.controller("UIChartController", [
  '$scope'
  '$state'
  ($scope, $state) ->

    $scope.addSeries = (ui_chart, series_title, group = null) ->
      if group
        # TODO: do something with the group
      else
        ui_chart.addSeries(series_title)
])
