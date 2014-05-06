/* global d3: false, nv: false, stream_layers: false, $: false */

$(document).ready(function() {
    //TODO: make this asynchronous
    function getSeriesList() {
        var dataSet = [];
        var tempoURI = '/series/list';
        $.ajax({
            url: tempoURI,
            async: false,
            success: function(data) {
                dataSet = data;
            }
        });
        return dataSet;
    }

    var seriesList = getSeriesList();

    function tempoDB(key) {
        var dataSet = [];
        var tempoURI = '/data/' + key;
        console.log(tempoURI);
        //TODO: make this async
        $.ajax({
            url: tempoURI,
            async: false,
            success: function(data) {
                console.log(data);
                var jsonObj=data;
                var arrayWithDateObjs = [];

                var arrayWithStringObjs = jsonObj[0].values;
                var arrayLength = arrayWithStringObjs.length;
                for (var i = 0; i < arrayLength; i++) {
                    arrayWithDateObjs.push({x: new Date(arrayWithStringObjs[i].ts), y: arrayWithStringObjs[i].value});
                }


                var o1 = {
                    key: jsonObj[0].key,
                    values: arrayWithDateObjs
                };
                dataSet.push(o1);
            }
        });
        return dataSet;
    }

    function addMyGraph(dataSet) {
        nv.addGraph(function() {
            var chart = nv.models.lineWithFocusChart(),
                formatString = '%-I:%M:%S:%L%p';

            chart.xAxis.tickFormat(function(d) {
                return d3.time.format(formatString)(new Date(d))
            });

            chart.x2Axis.tickFormat(function(d) {
                return d3.time.format(formatString)(new Date(d))
            });

            chart.yAxis.tickFormat(d3.format(',.2f'));
            chart.y2Axis.tickFormat(d3.format(',.2f'));
            d3.select('#chart svg').datum(dataSet).call(chart);

            nv.utils.windowResize(chart.update);

            return chart;
        });
    }

    function addMyJSONGraph() {
        var key = encodeURIComponent($('#tempodb-series-key').val());
        var dataSet = tempoDB(key);
        addMyGraph(dataSet);
    }

    // Setup Autocomplete for series name
    $("#tempodb-series-key").autocomplete({
        minLength: 0,
        source: function (request, response) {
            var term = request.term,
                matcher = new RegExp($.ui.autocomplete.escapeRegex(term), "i");

            response($.grep(seriesList, function (item) {
                return matcher.test(item.key + item.tags.join(', '));
            }));
        },
        focus: function(event, ui) {
            $("#tempodb-series-key").val(ui.item.key);
            return false;
        },
        select: function(event, ui) {
            $("#tempodb-series-key").val(ui.item.key);
            $("#series-name").html("Name: " + ui.item.name);
            $("#series-tags").html("Tags: " + ui.item.tags.join(', '));
            $("#series-attributes").html("Attributes: " + JSON.stringify(ui.item.attributes));
            addMyJSONGraph();
            return false;
        }
    }).data("ui-autocomplete")._renderItem = function(ul, item) {
        return $("<li>")
                .append("<a>" + item.key +
                        "<p style='font-size: small; padding: 0; margin: 0'>Tags:" +
                        item.tags.join(', ') + "</p></a>")
                .appendTo( ul );
    };




    var chartSeries = {},
        tmpArr, i, d;

    // 3 Sample Series in one graph
    chartSeries['3Series'] = stream_layers(3, 128, 0.1).map(function(data, i) {
        return { key: 'Stream' + i, values: data };
    });

    //Ints
    tmpArr = [];
    for(i = 0; i < 400; i++) {
        tmpArr.push({ x: i, y: i / (2.0 * Math.random()) });
    }
    chartSeries.randomPeaks = [{ key: "My Test", values: tmpArr }];

    //X-Axis: Dates down to the millisecond
    //Y-Axis: random increasing line
    //Gets noticeable lag when I have 4000 data points
    tmpArr = [];
    for(i = 0; i < 2000; i++) {
        d = new Date();

        // each sample gets farther apart -- showcases time scale
        d.setMilliseconds(d.getMilliseconds() + i*i);
        tmpArr.push({ x: d, y: i + (1000.0 * Math.random()) });
    }
    chartSeries.randomFreq = [{ key: "My Test", values: tmpArr }];

    // Get chart data from a JSON file
    $.getJSON('/fixtures/sample_chart.json', function(data) {
        var arrayWithDateObjs = [],
            arrayWithStringObjs = data[0].values,
            arrayLength = arrayWithStringObjs.length;

        for (i = 0; i < arrayLength; i++) {
            arrayWithDateObjs.push({
                x: new Date(arrayWithStringObjs[i].x),
                y: arrayWithStringObjs[i].y
            });
        }

        chartSeries.jsonDate = [{ key: data[0].key, values: arrayWithDateObjs }];
    });

    $('.graph_button').click(function (e) {
        e.preventDefault();
        $('.graph_button.active').removeClass('active');
        $(this).addClass('active');

        var chart = $(this).data('chart'),
            action = $(this).data('action');

        if (chart) {
            addMyGraph(chartSeries[chart]);
        } else if (action) {
            window[action].call();
        }
    });
});
