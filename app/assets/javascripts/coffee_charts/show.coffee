$(document).ready ->
  window.chart = new SciView.FocusChart(
    element: "#chart"
    url: d3.select("#chart").attr('data-source-url')
  )

  chart.getData()

