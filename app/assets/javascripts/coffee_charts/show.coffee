$(document).ready ->
  chart = new SciView.FocusChart("#chart")
  window.chart = chart

  $.ajax({
    url:  d3.select(chart.element).attr('data-source-url')
    success: (data) ->
      chart.data(data).render()
  })

