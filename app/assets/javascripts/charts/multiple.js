$(document).ready(function() {
  $('.chart').each(function(i,el){   
    window.chart = new SciView.FocusChart({
      element: el,
      url: d3.select(el).attr('data-source-url')
    })
    
    chart.getData()

//    $("#series-key").text(String(chartData[0].key));
//    
//    $.each( chartData[0].tags, function( index, value ){
//      addTagButton (value);
//    });
//    
//    $.each( chartData[0].attributes, function( key, value ) {
//      addAttributeButton (key, value);
//    });

  });
});
