
# Top-level namespace
window.SciView = {}

class SciView.BasicChart
  constructor: (options = {}) ->
    @element = options.element or 'body'
    @margin  = {top: 10, right: 10, bottom: 100, left: 40}
    @margin2 = {top: 430, right: 10, bottom: 20, left: 40}
    @width   = 960 - @margin.left - @margin.right
    @height  = 500 - @margin.top - @margin.bottom
    @height2 = 500 - @margin2.top - @margin2.bottom



class SciView.FocusChart extends SciView.BasicChart
  constructor: (options = {}) ->
    super(options)
    @_dataURL  = options.url
    @x         = d3.time.scale().range([0, @width])
    @x2        = d3.time.scale().range([0, @width])
    @y         = d3.scale.linear().range([@height, 0])
    @y2        = d3.scale.linear().range([@height2, 0])
    @xAxis     = d3.svg.axis().scale(@x).orient("bottom")
    @xAxis2    = d3.svg.axis().scale(@x2).orient("bottom")
    @yAxis     = d3.svg.axis().scale(@y).orient("left")

    @brush = d3.svg.brush()
      .x(@x2)
      .on("brush", @brushed)
      .on("brushend", @brushEnd)

    #@focusBrush = d3.svg.brush()
    #.x(@x)
    #.on("brushend", =>
    #@brush.extent(@focusBrush.extent())
    #@focusBrush.clear()
    #@focus.select('g.brush').call(@focusBrush)
    #@context.select('g.brush').call(@brush)
    #@brushEnd()
    #)

    @lineFocus = d3.svg.line()
      .x((d) => @x(d.x))
      .y((d) => @y(d.y))
      .interpolate('linear')

    @lineContext = d3.svg.line()
      .x((d) => @x2(d.x))
      .y((d) => @y2(d.y))

    @initializeSvg()

  # Data loading
  # #################################################
 
  # if argument is present, set data and return self;
  # otherwise return current data
  data: (d) ->
    if d
      if @_data # initial data set has already been loaded, and should be kept as the low-fi data set
        @zoomData(d)
      else
        @_data = preprocess(d)
      return @
    @_data

  # higher-fidelity data over a narrower domain
  zoomData: (d) ->
    if d
      @_zoomData = preprocess(d)
      @isZoomed  = true
      return @
    @_zoomData

  # Trigger the ajax call.
  getData: ->
    $.ajax({
      url: "#{@dataURL()}#{@startStopQuery()}&count=960"
      success: (data) =>
        @data(data)
        @render()
    })

  # Stores the data in a renderable format:
  # [ { key: "some key", values: [ { x: 10, y: 20 }, { x: 20, y: 30 } ]} ... ]
  preprocess = (data) ->
    {
      key: s.key
      values: ({ x: new Date(d.ts), y: d.value } for d in s.values )
    } for _, s of data

  dataURL: (string) ->
    if string
      @_dataURL = string
      return @
    @_dataURL

  dateString = (t) -> new Date(t).toISOString()

  startStopQuery: ->
    return "" if @brush.empty()
    extents = (dateString(t) for t in @brush.extent())
    "&start_time=#{extents[0]}&stop_time=#{extents[1]}"

  # Brushing functions
  ########################################

  brushed: =>
    @x.domain(if @brush.empty() then @x2.domain() else @brush.extent())
    @focus.selectAll(".line.zoom").remove()
    @focus.selectAll(".line.focus")
      .attr('opacity', 1)
      .attr("d", (d) => @lineFocus(d.values))
    @focus.select(".x.axis").call(@xAxis)

  brushEnd: =>
    @getData() unless @brush.empty()

  # Dragging
  ###############################################

  dragged: =>
    d3.event.sourceEvent.stopPropagation()
    return if @brush.empty()
    dx = d3.event.dx


    dx_time = @x.invert(dx)
    # move as a percentage of range:
    pct = (dx / Math.abs(@x.range()[0] - @x.range()[1]))
    extent = @brush.extent()
    e.setSeconds(e.getSeconds() - dx) for e in extent
    @brush.extent(extent)

    @context.select('g.brush').call(@brush)
    @brushed()


  dragStart: ->
    d3.event.sourceEvent.stopPropagation()

  dragEnd: ->
    d3.event.sourceEvent.stopPropagation()




  # Rendering functions
  ################################################

  initializeSvg: =>
    @svg = d3.select(@element).append("svg")
      .attr("width", @width + @margin.left + @margin.right)
      .attr("height", @height + @margin.top + @margin.bottom)
    @svg.append("defs").append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", @width)
      .attr("height", @height)
    @focus = @svg.append("g")
      .attr("class", "focus")
      .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")
    @context = @svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + @margin2.left + "," + @margin2.top + ")")

  lineColor = d3.scale.category10()

  render: ->
    if @_zoomData
      @renderZoomData()
    else
      @renderInitialData()

  renderZoomData: ->
    @focus.selectAll('.init').attr('opacity', 0)
    zoomFocusPaths = @focus.selectAll('path.focus.zoom').data(@_zoomData)
    zoomFocusPaths.enter()
      .append('path')
      .attr('class', 'line focus zoom')
      .attr('clip-path', "url(#clip)")
      .style('stroke', (d) -> lineColor(d.key))
    zoomFocusPaths.attr('d', (d) => @lineFocus(d.values))
    zoomFocusPaths.exit().remove()
  
  renderInitialData: ->
    all_data = @_data.map((obj) -> obj.values).reduce((a, b) -> a.concat(b))

    @x.domain(d3.extent(all_data.map((d) -> d.x )))
    @y.domain(d3.extent(all_data.map((d) -> d.y )))
    @x2.domain(@x.domain())
    @y2.domain(@y.domain())

    @drag = d3.behavior.drag()
      .on("dragstart", @dragStart)
      .on("drag", @dragged)
      .on("dragend", @dragEnd)

    @focusTarget = @focus.append('rect')
      .attr('class', 'focusTarget')
      .attr('x', 0)
      .attr('y', 0)
      .attr('height', @height2)
      .attr('width', @width)
      .style('fill', 'red')
      .attr('width', 960)
    @focusTarget.call(@drag)

    focusPaths = @focus.selectAll('path.focus.init').data(@_data)
    focusPaths.enter()
      .append('path')
      .attr('class', 'line focus init')
      .attr('d', (d) => @lineFocus(d.values))
      .attr("clip-path", "url(#clip)")
      .style('stroke', (d) -> lineColor(d.key))
    @focus.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @height + ")")
      .call(@xAxis)
    @focus.append("g")
      .attr("class", "y axis")
      .call(@yAxis)

    contextPaths = @context.selectAll("path.context").data(@_data)
    contextPaths.enter()
      .append('path')
      .attr("class", "line context")
      .attr("d", (d) => @lineContext(d.values))
      .style('stroke', (d) -> lineColor(d.key))
    @context.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @height2 + ")")
      .call(@xAxis2)
    @context.append("g")
      .attr("class", "x brush")
      .call(@brush)
      .selectAll("rect")
      .attr("y", -6)
      .attr("height", @height2 + 7)
    # @focus.append("g")
    #   .attr("class", "x brush")
    #   .call(@focusBrush)
    #   .selectAll("rect")
    #   .attr("y", -6)
    #   .attr("height", @height)

