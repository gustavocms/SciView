$(document).ready(function() {
    $.ajax({
        url: $("#chart").data("source-url"),
        success: function(data) {
            values = data[0].values.map(function(elem) {
                return {x: new Date(elem.ts),
                        y: elem.value};
            });

            chartData = [{ key: data[0].key,
                           values: values }];
            nv.addGraph(function() {
                var chart = nv.models.lineWithFocusChart(),
                    formatString = '%-I:%M:%S:%L%p';

                chart.xAxis.tickFormat(function(d) {
                    return d3.time.format(formatString)(new Date(d));
                });

                chart.x2Axis.tickFormat(function(d) {
                    return d3.time.format(formatString)(new Date(d));
                });

                chart.yAxis.tickFormat(d3.format(',.2f'));
                chart.y2Axis.tickFormat(d3.format(',.2f'));
                d3.select('#chart svg').datum(chartData).call(chart);

                nv.utils.windowResize(chart.update);

                return chart;
            });
        }
    });
});
