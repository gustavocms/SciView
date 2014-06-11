$(document).ready ->
  chart = new SciView.FocusChart("#chart")
  chart.loadCSVData("sp500.csv")
  window.chart = chart
