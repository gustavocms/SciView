$(document).ready(
    function(){
        var i,
            series = {},
            arr = [],
            d = new Date(),
            jsonObj = JSON.parse('[{"key":"My Test2","values":[{"x":"2014-04-05T04:00:58.743Z","y":461.38070384040475},{"x":"2014-04-05T04:00:58.744Z","y":978.1196029614657},{"x":"2014-04-05T04:00:58.748Z","y":894.8572814911604},{"x":"2014-04-05T04:00:58.757Z","y":374.3492101524025},{"x":"2014-04-05T04:00:58.773Z","y":710.2243900727481},{"x":"2014-04-05T04:00:58.798Z","y":912.9113295301795},{"x":"2014-04-05T04:00:58.834Z","y":222.1391032859683},{"x":"2014-04-05T04:00:58.883Z","y":521.2049149144441},{"x":"2014-04-05T04:00:58.947Z","y":874.4522205945104},{"x":"2014-04-05T04:00:59.028Z","y":607.1796341948211},{"x":"2014-04-05T04:00:59.128Z","y":704.2579140886664},{"x":"2014-04-05T04:00:59.249Z","y":105.42167007364333},{"x":"2014-04-05T04:00:59.393Z","y":567.5727006867528},{"x":"2014-04-05T04:00:59.562Z","y":15.801120979711413},{"x":"2014-04-05T04:00:59.758Z","y":193.68738288618624},{"x":"2014-04-05T04:00:59.983Z","y":166.65070397779346},{"x":"2014-04-05T04:01:00.239Z","y":17.547104446217418},{"x":"2014-04-05T04:01:00.528Z","y":220.49996746517718},{"x":"2014-04-05T04:01:00.852Z","y":413.3329345677048},{"x":"2014-04-05T04:01:01.213Z","y":844.1037932932377},{"x":"2014-04-05T04:01:01.613Z","y":251.22459230944514},{"x":"2014-04-05T04:01:02.054Z","y":268.8948791977018},{"x":"2014-04-05T04:01:02.538Z","y":858.7891472298652},{"x":"2014-04-05T04:01:03.067Z","y":513.3603733982891},{"x":"2014-04-05T04:01:03.643Z","y":540.6385907214135},{"x":"2014-04-05T04:01:04.268Z","y":579.7200664877892},{"x":"2014-04-05T04:01:04.944Z","y":532.3833589665592},{"x":"2014-04-05T04:01:05.673Z","y":230.0430776067078},{"x":"2014-04-05T04:01:06.457Z","y":199.38039786368608},{"x":"2014-04-05T04:01:07.298Z","y":556.2996556013823},{"x":"2014-04-05T04:01:08.198Z","y":393.6536335106939},{"x":"2014-04-05T04:01:09.159Z","y":108.08701910451055},{"x":"2014-04-05T04:01:10.183Z","y":472.6847534701228},{"x":"2014-04-05T04:01:11.272Z","y":487.35303170233965},{"x":"2014-04-05T04:01:12.428Z","y":415.8982527591288},{"x":"2014-04-05T04:01:13.653Z","y":565.0705670379102},{"x":"2014-04-05T04:01:14.949Z","y":925.4716470967978},{"x":"2014-04-05T04:01:16.318Z","y":384.8018301539123}]}]'),
            arrayWithDateObjs = [],
            arrayWithStringObjs = jsonObj[0].values;

        series.data1 = stream_layers(3,128,0.1).map(function(data, i) {
            return {
                key: 'Stream' + i,
                values: data
            };
        });

        //Ints
        for(i=0; i<400; i++) {
            arr.push( { x: i, y: i / (2.0 * Math.random() ) });
        }
        series.data2 = [{
            key: "My Test",
            values: arr
        }];

        //X-Axis: Dates down to the millisecond
        //Y-Axis: random increasing line
        //Gets noticeable lag when I have 4000 data points
        arr = [];
        for(i=0; i<2000; i++) {
            d.setMilliseconds(d.getMilliseconds() + i*i); // each sample gets farther apart -- showcases time scale
            arr.push({ x: new Date(d.getTime()),
                  y: i + (1000.0 * Math.random() ) });
        }
        series.data3 = [{
            key: "My Test",
            values: arr
        }];


        for (i = 0; i < arrayWithStringObjs.length; i++) {
            arrayWithDateObjs.push({
                x: new Date(arrayWithStringObjs[i].x),
                y: arrayWithStringObjs[i].y
            });
        }

        series.data4 = [{
            key: jsonObj[0].key,
            values: arrayWithDateObjs
        }];

        function addMyGraph(dataSet) {
            nv.addGraph(function() {
                var chart = nv.models.lineWithFocusChart(),
                //D3 Time Formatting: https://github.com/mbostock/d3/wiki/Time-Formatting
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

        $('.sample-graph').click(function(e) {
            e.preventDefault();

            var dataSeries = $(this).data('series');
            addMyGraph(series[dataSeries]);
        });

        $('.tempodb-graph').click(function(e) {
            e.preventDefault();

            var dataSet = [],
                key = $('tempodb-series-key').val(),
                tempoURI = '/data/' + key.replace(/\./, '%2E');

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


                    var o1 = [{
                        key: jsonObj[0].key,
                values: arrayWithDateObjs
                    }];
                    addMyGraph(o1);
                }
            });
        });

    }
);





