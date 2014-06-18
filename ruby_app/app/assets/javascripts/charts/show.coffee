$(document).ready ->
  new SciView.FocusChart(
    element: "#chart"
    url: d3.select("#chart").attr('data-source-url')
  ).getData()

