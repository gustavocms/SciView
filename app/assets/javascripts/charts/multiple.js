  $(document).ready(function() {
    //============================================================
    // Adapted from NVD3's "lineWithFocusChart"
    //------------------------------------------------------------

    "use strict";
    //============================================================
    // Public Variables with Default Settings
    //------------------------------------------------------------

    var lines = nv.models.line()
      , lines2 = nv.models.line()
      , xAxis = nv.models.axis()
      , yAxis = nv.models.axis()
      , x2Axis = nv.models.axis()
      , y2Axis = nv.models.axis()
      , legend = nv.models.legend()
      , brush = d3.svg.brush()
    ;

    var margin = {top: 30, right: 30, bottom: 30, left: 60}
      , margin2 = {top: 0, right: 30, bottom: 20, left: 60}
      , color = nv.utils.defaultColor()
      , width = null
      , height = null
      , height2 = 100
      , x
      , y
      , x2
      , y2
      , showLegend = true
      , brushExtent = null
      , tooltips = true
      , tooltip = function(key, x, y, e, graph) {
                      return '<h3>' + key + '</h3>' +
                             '<p>' +  y + ' at ' + x + '</p>'
                  }
      , noData = "No Data Available."
      , dispatch = d3.dispatch('tooltipShow', 'tooltipHide', 'brush')
      , transitionDuration = 250
    ;

    lines
        .clipEdge(true)
    ;
    lines2
        .interactive(false)
    ;
    xAxis
        .orient('bottom')
        .tickPadding(5)
    ;
    yAxis
        .orient('left')
    ;
    x2Axis
        .orient('bottom')
        .tickPadding(5)
    ;
    y2Axis
        .orient('left')
    ;
    //============================================================


    //============================================================
    // Private Variables
    //------------------------------------------------------------

    var showTooltip = function(e, offsetElement) {
        var left = e.pos[0] + ( offsetElement.offsetLeft || 0 ),
            top = e.pos[1] + ( offsetElement.offsetTop || 0),
            x = xAxis.tickFormat()(lines.x()(e.point, e.pointIndex)),
            y = yAxis.tickFormat()(lines.y()(e.point, e.pointIndex)),
            content = tooltip(e.series.key, x, y, e, chart);

        nv.tooltip.show([left, top], content, null, null, offsetElement);
    };

    //============================================================


    function chart(selection) {
        selection.each(function(data) {
            var container = d3.select(this),
                that = this;

            var availableWidth = (width  || parseInt(container.style('width')) || 960)
                                    - margin.left - margin.right,
                availableHeight1 = (height || parseInt(container.style('height')) || 400)
                                    - margin.top - margin.bottom - height2,
                availableHeight2 = height2 - margin2.top - margin2.bottom;

                chart.update = function() {
                    container.transition().duration(transitionDuration).call(chart)
                };
                chart.container = this;


            //------------------------------------------------------------
            // Display No Data message if there's nothing to show.

            if (!data || !data.length || !data.filter(function(d) {
                return d.values.length }).length) {
                    var noDataText = container.selectAll('.nv-noData').data([noData]);

                    noDataText.enter().append('text')
                        .attr('class', 'nvd3 nv-noData')
                        .attr('dy', '-.7em')
                        .style('text-anchor', 'middle');

                        noDataText
                            .attr('x', margin.left + availableWidth / 2)
                            .attr('y', margin.top + availableHeight1 / 2)
                            .text(function(d) { return d });

                return chart;
            } else {
                container.selectAll('.nv-noData').remove();
            }

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Setup Scales

            x = lines.xScale();
            y = lines.yScale();
            x2 = lines2.xScale();
            y2 = lines2.yScale();

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Setup containers and skeleton of chart

            
            var wrap = container.selectAll('g.nv-wrap.nv-lineWithFocusChart').data([data]);
            var gEnter = wrap.enter().append('g').attr('class', 'nvd3 nv-wrap nv-lineWithFocusChart').append('g');
            var g = wrap.select('g');

            gEnter.append('g').attr('class', 'nv-legendWrap');

            var focusEnter = gEnter.append('g').attr('class', 'nv-focus');

            //
            var focusTarget = focusEnter.append('rect')
                .attr('class', 'focusTarget')
                .style('fill', 'white')
                .style('opacity', 0)
                .attr('x', 0)
                .attr('y', 0)
                .attr('width', availableWidth)
                .attr('height', availableHeight1)
                .on('click', function() {
                    if (d3.event.defaultPrevented) return;
                    clearBrush();
                });

            focusEnter.append('g').attr('class', 'nv-x nv-axis');
            focusEnter.append('g').attr('class', 'nv-y nv-axis');
            focusEnter.append('g').attr('class', 'nv-linesWrap');

            var contextEnter = gEnter.append('g').attr('class', 'nv-context');
            contextEnter.append('g').attr('class', 'nv-x nv-axis');
            contextEnter.append('g').attr('class', 'nv-y nv-axis');
            contextEnter.append('g').attr('class', 'nv-linesWrap');
            contextEnter.append('g').attr('class', 'nv-brushBackground');
            contextEnter.append('g').attr('class', 'nv-x nv-brush');

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Legend

            if (showLegend) {
                legend.width(availableWidth);

                g.select('.nv-legendWrap')
                .datum(data)
                .call(legend);

                if ( margin.top != legend.height()) {
                    margin.top = legend.height();
                    availableHeight1 = (height || parseInt(container.style('height')) || 400)
                    - margin.top - margin.bottom - height2;
                }

                g.select('.nv-legendWrap')
                .attr('transform', 'translate(0,' + (-margin.top) +')')
            }

            //------------------------------------------------------------


            wrap.attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');


            //------------------------------------------------------------
            // Main Chart Component(s)

            lines
            .width(availableWidth)
            .height(availableHeight1)
            .color(
                data
                .map(function(d,i) {
                    return d.color || color(d, i);
                })
                .filter(function(d,i) {
                    return !data[i].disabled;
                })
            );

            lines2
            .defined(lines.defined())
            .width(availableWidth)
            .height(availableHeight2)
            .color(
                data
                .map(function(d,i) {
                    return d.color || color(d, i);
                })
                .filter(function(d,i) {
                    return !data[i].disabled;
                })
            );

            g.select('.nv-context')
            .attr('transform', 'translate(0,' + ( availableHeight1 + margin.bottom + margin2.top) + ')')

            var contextLinesWrap = g.select('.nv-context .nv-linesWrap')
            .datum(data.filter(function(d) { return !d.disabled }))

            d3.transition(contextLinesWrap).call(lines2);

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Setup Main (Focus) Axes

            xAxis
            .scale(x)
            .ticks( availableWidth / 100 )
            .tickSize(-availableHeight1, 0);

            yAxis
            .scale(y)
            .ticks( availableHeight1 / 36 )
            .tickSize( -availableWidth, 0);

            g.select('.nv-focus .nv-x.nv-axis')
            .attr('transform', 'translate(0,' + availableHeight1 + ')');

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Setup Brush
            
            //When brushing, turn off transitions because chart needs to change immediately.
            function skipTransitionsFor(someFunction) {
                return function(){
                    var oldTransition = chart.transitionDuration();
                    chart.transitionDuration(0);
                    someFunction();
                    chart.transitionDuration(oldTransition);
                };
            };

            brush
            .x(x2)
            .on('brush', skipTransitionsFor(onBrush));

            if (brushExtent) brush.extent(brushExtent);

            var brushBG = g.select('.nv-brushBackground').selectAll('g')
            .data([brushExtent || brush.extent()])

            var brushBGenter = brushBG.enter()
            .append('g');

            brushBGenter.append('rect')
            .attr('class', 'left')
            .attr('x', 0)
            .attr('y', 0)
            .attr('height', availableHeight2);

            brushBGenter.append('rect')
            .attr('class', 'right')
            .attr('x', 0)
            .attr('y', 0)
            .attr('height', availableHeight2);

            var gBrush = g.select('.nv-x.nv-brush')
            .call(brush);
            gBrush.selectAll('rect')
            //.attr('y', -5)
            .attr('height', availableHeight2);
            gBrush.selectAll('.resize').append('path').attr('d', resizePath);

            onBrush();

            function clearBrush() {
              brush.clear();
              gBrush.selectAll(".resize").style("display", "none");
              gBrush.select('rect.extent').attr('width', 0);
              skipTransitionsFor(onBrush)();
            }


            function updateResizeHandlePlacement() {
              var extents = brush.extent().map(x2);
              gBrush.select(".resize.w").attr("transform", "translate(" + extents[0] + ",0)");
              gBrush.select(".resize.e").attr("transform", "translate(" + extents[1] + ",0)");
            }

            //------------------------------------------------------------


            //------------------------------------------------------------
            // Setup Secondary (Context) Axes

            x2Axis
            .scale(x2)
            .ticks( availableWidth / 100 )
            .tickSize(-availableHeight2, 0);

            g.select('.nv-context .nv-x.nv-axis')
            .attr('transform', 'translate(0,' + y2.range()[0] + ')');
            d3.transition(g.select('.nv-context .nv-x.nv-axis'))
            .call(x2Axis);


            y2Axis
            .scale(y2)
            .ticks( availableHeight2 / 36 )
            .tickSize( -availableWidth, 0);

            d3.transition(g.select('.nv-context .nv-y.nv-axis'))
            .call(y2Axis);

            g.select('.nv-context .nv-x.nv-axis')
            .attr('transform', 'translate(0,' + y2.range()[0] + ')');

            //------------------------------------------------------------


            // drag-to-pan behavior
            var drag = d3.behavior.drag()
            .origin(function(d){ return d; })
            .on("dragstart", dragStart)
            .on("drag", dragged)
            .on("dragend", dragEnd);

            function dragStart() { 
                d3.event.sourceEvent.stopPropagation();
                gBrush.select('.extent').attr('stroke', 'red');
            };

            function dragged(){
                if (brush.empty()) return;
                var extent_rectangle = gBrush.select('.extent'),
                    dx               = d3.event.dx,
                    current_x        = parseFloat(extent_rectangle.attr('x'));
                extent_rectangle.attr('x', current_x - (dx * portionShown()));
            };

            // reverse scale (swap domain and range)
            var _x2 = d3.scale.linear()
                .domain(x2.range())
                .range(x2.domain())

            function setBrushExtentsFromBBox() {
                var current_extent = brush.extent(),
                    bbox           = gBrush.select('rect.extent'),
                    bbox_x         = parseFloat(bbox.attr('x')),
                    bbox_width     = parseFloat(bbox.attr('width')),
                    new_west       = _x2(bbox_x),
                    new_east       = _x2(bbox_x + bbox_width);

                brush.extent([new_west, new_east]);
            };

            function dragEnd(){
                setBrushExtentsFromBBox();
                skipTransitionsFor(onBrush)();
                updateResizeHandlePlacement();
                gBrush.select('.extent').attr('stroke', 'none');
            };


            function portionShown() {
                var x2d    = x2.domain();
                var extent = brush.empty() ? x2 : brush.extent();
                return (extent[1] - extent[0]) / (x2d[1] - x2d[0]);
            };


            focusTarget.call(drag);

            // scroll-to-zoom behavior
            var zoom = d3.behavior.zoom()
            .on('zoomstart', zoomStart)
            .on('zoom', zoomed)
            .on('zoomend', dragEnd);

            function zoomStart(){
              zoom.scale(1); // keep the scale relative (otherwise, it is a persistent value in the zoom object)
              if (brush.empty()){
                // setup the brush if it's not already in use
                gBrush.select('.extent').attr('x', 0).attr('width', availableWidth);
                setBrushExtentsFromBBox();
              }

              gBrush.select('.extent').attr('stroke', 'red');
            };


            function zoomed(){ 
              var current_extent = brush.extent(),
                  // below in pixels
                  extent_west   = x2(current_extent[0]),
                  extent_east   = x2(current_extent[1]),
                  current_range = extent_east - extent_west,
                  // scroll up to zoom in (smaller range),
                  // down to zoom out (larger range)
                  new_range        = current_range * d3.event.scale,
                  limiting_factor  = 20, // keep it from going wild (this should eventually be based on the current zoom window)
                  extent_delta     = (current_range - new_range) / limiting_factor,
                  extent_rectangle = gBrush.select('rect.extent'),
                  current_x        = parseFloat(extent_rectangle.attr('x')),
                  current_width    = parseFloat(extent_rectangle.attr('width')),

                  // prevent out-of-bounds extents
                  new_x     = Math.max(current_x - extent_delta, 0),
                  max_width = availableWidth - new_x,
                  new_width = Math.min(max_width, Math.max(availableWidth * 0.005, current_width + (2 * extent_delta)));


              if (new_x == 0 && new_width == availableWidth){
                clearBrush();
              } else if (current_width != new_width) {
                extent_rectangle.attr('x', new_x).attr('width', new_width);
              };
            };

            focusTarget.call(zoom);

            //============================================================
            // Event Handling/Dispatching (in chart's scope)
            //------------------------------------------------------------

            legend.dispatch.on('stateChange', function(newState) { 
                chart.update();
            });

            dispatch.on('tooltipShow', function(e) {
                if (tooltips) showTooltip(e, that.parentNode);
            });

            //============================================================


            //============================================================
            // Functions
            //------------------------------------------------------------

            // Taken from crossfilter (http://square.github.com/crossfilter/)
            function resizePath(d) {
                var e = +(d == 'e'),
                x = e ? 1 : -1,
                y = availableHeight2 / 3;
                return 'M' + (.5 * x) + ',' + y
                + 'A6,6 0 0 ' + e + ' ' + (6.5 * x) + ',' + (y + 6)
                + 'V' + (2 * y - 6)
                + 'A6,6 0 0 ' + e + ' ' + (.5 * x) + ',' + (2 * y)
                + 'Z'
                + 'M' + (2.5 * x) + ',' + (y + 8)
                + 'V' + (2 * y - 8)
                + 'M' + (4.5 * x) + ',' + (y + 8)
                + 'V' + (2 * y - 8);
            }


            function updateBrushBG() {
                if (!brush.empty()) brush.extent(brushExtent);
                brushBG
                .data([brush.empty() ? x2.domain() : brushExtent])
                .each(function(d,i) {
                    var leftWidth = x2(d[0]) - x.range()[0],
                    rightWidth = x.range()[1] - x2(d[1]);
                    d3.select(this).select('.left')
                    .attr('width',  leftWidth < 0 ? 0 : leftWidth);

                    d3.select(this).select('.right')
                    .attr('x', x2(d[1]))
                    .attr('width', rightWidth < 0 ? 0 : rightWidth);
                });
            }

            var pendingChartUpdate = null,
                pendingUpdateRequest = null;

            function updateChart(disabled_serie) {
                if (pendingUpdateRequest) {
                    pendingUpdateRequest.abort();
                }

                brushExtent = brush.empty() ? null : brush.extent();
                var extent = brush.empty() ? x2.domain() : brush.extent(),
                    startTime = new Date(extent[0]).toISOString(),
                    stopTime = new Date(extent[1]).toISOString(),
                    startStopQuery = "&start_time="+startTime+"&stop_time="+stopTime;

                pendingUpdateRequest = $.ajax({
                    url: $(".chart").data("source-url") + "&count=960" + startStopQuery,
                    success: function(data) {
                        var chartData;
                        pendingUpdateRequest = null;

                        chartData = [];

                        $.each(data, function(i, series_data){
                          var values;
                          values = series_data.values.map(function(elem) {
                              return {x: new Date(elem.ts),
                                      y: elem.value};
                          });
                          if (!disabled_serie.match(series_data.key)) {
                            chartData.push( { key: series_data.key,
                                              values: values } );                            
                          } else {
                            chartData.push( { key: series_data.key,
                                              values: [] } );                              
                          };
                          

                        });
                        var focusLinesWrap = g.select('.nv-focus .nv-linesWrap')
                        
  

                        // Update Main (Focus)
                        focusLinesWrap
                            .datum(
                                chartData
                                    .filter(function(d) { return !d.disabled; })
                                    .map(function(d,i) {
                                        return {
                                            key: d.key,
                                            values: d.values.filter(function(d,i) {
                                                return lines.x()(d,i) >= extent[0] && lines.x()(d,i) <= extent[1];
                                            })
                                        };
                                    })
                            );

                        focusLinesWrap.transition().duration(transitionDuration).call(lines);
                    }
                });
            }

            function queueChartUpdate() {
                var disabled_serie = d3.select('.nv-series.disabled').empty() ? '' : d3.select('.nv-series.disabled').text()

                if (pendingChartUpdate) {
                    window.clearTimeout(pendingChartUpdate);
                }
                pendingChartUpdate = setTimeout(function() { pendingChartUpdate = null; updateChart(disabled_serie); }, 500);
            }

            function onBrush() {
                brushExtent = brush.empty() ? null : brush.extent();
                var extent = brush.empty() ? x2.domain() : brush.extent();

                //The brush extent cannot be less than one.  If it is, don't update the line chart.
                if (Math.abs(extent[0] - extent[1]) <= 1) {
                    return;
                }

                dispatch.brush({extent: extent, brush: brush});

                var focusLinesWrap = g.select('.nv-focus .nv-linesWrap');
                focusLinesWrap.transition().duration(transitionDuration).call(lines);

                queueChartUpdate();

                updateBrushBG();

                // Update Main (Focus) Axes
                g.select('.nv-focus .nv-x.nv-axis').transition().duration(transitionDuration)
                    .call(xAxis);
                g.select('.nv-focus .nv-y.nv-axis').transition().duration(transitionDuration)
                    .call(yAxis);
            }

            //============================================================


        });

        return chart;
    }


    //============================================================
    // Event Handling/Dispatching (out of chart's scope)
    //------------------------------------------------------------

    lines.dispatch.on('elementMouseover.tooltip', function(e) {
        e.pos = [e.pos[0] +  margin.left, e.pos[1] + margin.top];
        dispatch.tooltipShow(e);
    });

    lines.dispatch.on('elementMouseout.tooltip', function(e) {
        dispatch.tooltipHide(e);
    });

    dispatch.on('tooltipHide', function() {
        if (tooltips) nv.tooltip.cleanup();
    });

    //============================================================


    //============================================================
    // Expose Public Variables
    //------------------------------------------------------------

    // expose chart's sub-components
    chart.dispatch = dispatch;
    chart.legend = legend;
    chart.lines = lines;
    chart.lines2 = lines2;
    chart.xAxis = xAxis;
    chart.yAxis = yAxis;
    chart.x2Axis = x2Axis;
    chart.y2Axis = y2Axis;

    d3.rebind(chart, lines, 'defined', 'isArea', 'size', 'xDomain', 'yDomain', 'xRange', 'yRange', 'forceX', 'forceY', 'interactive', 'clipEdge', 'clipVoronoi', 'id');

    chart.options = nv.utils.optionsFunc.bind(chart);

    chart.x = function(_) {
        if (!arguments.length) return lines.x;
        lines.x(_);
        lines2.x(_);
        return chart;
    };

    chart.y = function(_) {
        if (!arguments.length) return lines.y;
        lines.y(_);
        lines2.y(_);
        return chart;
    };

    chart.margin = function(_) {
        if (!arguments.length) return margin;
        margin.top    = typeof _.top    != 'undefined' ? _.top    : margin.top;
        margin.right  = typeof _.right  != 'undefined' ? _.right  : margin.right;
        margin.bottom = typeof _.bottom != 'undefined' ? _.bottom : margin.bottom;
        margin.left   = typeof _.left   != 'undefined' ? _.left   : margin.left;
        return chart;
    };

    chart.margin2 = function(_) {
        if (!arguments.length) return margin2;
        margin2 = _;
        return chart;
    };

    chart.width = function(_) {
        if (!arguments.length) return width;
        width = _;
        return chart;
    };

    chart.height = function(_) {
        if (!arguments.length) return height;
        height = _;
        return chart;
    };

    chart.height2 = function(_) {
        if (!arguments.length) return height2;
        height2 = _;
        return chart;
    };

    chart.color = function(_) {
        if (!arguments.length) return color;
        color =nv.utils.getColor(_);
        legend.color(color);
        return chart;
    };

    chart.showLegend = function(_) {
        if (!arguments.length) return showLegend;
        showLegend = _;
        return chart;
    };

    chart.tooltips = function(_) {
        if (!arguments.length) return tooltips;
        tooltips = _;
        return chart;
    };

    chart.tooltipContent = function(_) {
        if (!arguments.length) return tooltip;
        tooltip = _;
        return chart;
    };

    chart.interpolate = function(_) {
        if (!arguments.length) return lines.interpolate();
        lines.interpolate(_);
        lines2.interpolate(_);
        return chart;
    };

    chart.noData = function(_) {
        if (!arguments.length) return noData;
        noData = _;
        return chart;
    };

    // Chart has multiple similar Axes, to prevent code duplication, probably need to link all axis functions manually like below
    chart.xTickFormat = function(_) {
        if (!arguments.length) return xAxis.tickFormat();
        xAxis.tickFormat(_);
        x2Axis.tickFormat(_);
        return chart;
    };

    chart.yTickFormat = function(_) {
        if (!arguments.length) return yAxis.tickFormat();
        yAxis.tickFormat(_);
        y2Axis.tickFormat(_);
        return chart;
    };

    chart.brushExtent = function(_) {
        if (!arguments.length) return brushExtent;
        brushExtent = _;
        return chart;
    };

    chart.transitionDuration = function(_) {
        if (!arguments.length) return transitionDuration;
        transitionDuration = _;
        return chart;
    };


    $('.chart').each(function(i,el){   
      var id = "#"+ $(el).prop('id')
      $.ajax({
        url: $(el).data("source-url"),
        success: function(data) {
          var formatString;
          var chartData = []
          $.each(data, function(i, series_data){
            var values;
            values = series_data.values.map(function(elem) {
                return {x: new Date(elem.ts),
                        y: elem.value};
            });
            chartData.push( { key: series_data.key,
                           values: values } );

          });
          nv.addGraph(function() {
              formatString = '%-I:%M:%S:%L%p';

              chart.xAxis.tickFormat(function(d) {
                  return d3.time.format(formatString)(new Date(d));
              });

              chart.x2Axis.tickFormat(function(d) {
                  return d3.time.format(formatString)(new Date(d));
              });

              chart.yAxis.tickFormat(d3.format(',.2f'));
              chart.y2Axis.tickFormat(d3.format(',.2f'));
              d3.select(id +' svg').datum(chartData).call(chart);

              nv.utils.windowResize(chart.update);

              return chart;
            });
          }
        });
    });

  });
