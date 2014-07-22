$(document).ready(function() {
  $('.chart').each(function(i,el){  
    disabledSeries = '' 
    if (d3.select(el).attr('data-disabled-series').length) {  disabledSeries = d3.select(el).attr('data-disabled-series').split(',') };
    window.chart = new SciView.FocusChart({
      element: el,
      url: d3.select(el).attr('data-source-url'),
      startTime: d3.select(el).attr('data-start-time'),
      stopTime:  d3.select(el).attr('data-stop-time'),
      disabledSeries: disabledSeries
    })


    chart.getData();
  });
});