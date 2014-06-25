
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

    @lineFocus = d3.svg.line()
      .x((d) => @x(d.x))
      .y((d) => @y(d.y))
      .interpolate('linear')

    @lineContext = d3.svg.line()
      .x((d) => @x2(d.x))
      .y((d) => @y2(d.y))

    @initializeSvg()

    @zoom = d3.behavior.zoom()
      .on('zoom', @zoomed)
      .on('zoomend', =>
        @zoomEnd()
      )

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
        loadMetadata()
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
      tags: s.tags
      attributes: s.attributes
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

  # Zooming and Dragging
  ###############################################

  zoomEnd: ->
    d3.event?.sourceEvent?.stopPropagation()
    @zoom.scale(1).translate([0, 0]) # keep movements relative
    @_dx_prev = 0
    @brushEnd()

  zoomed: =>
    d3.event.sourceEvent.stopPropagation()
    ({ # event types (MouseEvent or WheelEvent)
      mousemove: @_zoomed_pan
      wheel: @_zoomed_zoom
    }[d3.event.sourceEvent.type] or (->))()

  _zoomed_zoom: =>
    if @brush.empty()
      extent_pixels = [0, @width]
    else
      extent_pixels = @brush.extent().map(@x2)
    brush_width   = Math.abs(extent_pixels[0] - extent_pixels[1])
    new_width     = brush_width * @zoom.scale()
    d_brush       = (new_width - brush_width) / 2

    x0 = extent_pixels[0] + d_brush
    x1 = extent_pixels[1] - d_brush
    x0 = 0 if x0 < 0
    x1 = @width if x1 > @width

    if x0 is 0 and x1 is @width
      @brush.clear()
    else
      @brush.extent([x0, x1].map(@x2.invert))

    @context.select('g.brush').call(@brush)
    @brushed()
    @zoom.scale(1) # keep this relative


  _zoomed_pan: =>
    return if @brush.empty()
    # For zoom events, the translation vector is absolute until 'zoomend'.
    # These three lines keep the vector relative to allow 1 - 1 pixel dragging.
    _dx       = d3.event.translate[0]
    dx        = _dx - (@_dx_prev or 0)
    @_dx_prev = _dx

    extent_pixels  = @brush.extent().map(@x2)
    brush_width    = Math.abs(extent_pixels[0] - extent_pixels[1])
    d_brush        = brush_width * dx / @width

    return if d3.min(extent_pixels) - d_brush < 0 # overflow left
    return if d3.max(extent_pixels) - d_brush > @width # overflow right

    @brush.extent(extent_pixels.map((x) => @x2.invert(x - d_brush)))
    @context.select('g.brush').call(@brush)
    @brushed()


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
      @_renderZoomData()
    else
      @_renderInitialData()

  _renderZoomData: ->
    @focus.selectAll('.init').attr('opacity', 0)
    zoomFocusPaths = @focus.selectAll('path.focus.zoom').data(@_zoomData)
    zoomFocusPaths.enter()
      .append('path')
      .attr('class', 'line focus zoom')
      .attr('clip-path', "url(#clip)")
      .style('stroke', (d) -> lineColor(d.key))
    zoomFocusPaths.attr('d', (d) => @lineFocus(d.values))
    zoomFocusPaths.exit().remove()
  
  _renderInitialData: ->
    all_data = @_data.map((obj) -> obj.values).reduce((a, b) -> a.concat(b))

    @x.domain(d3.extent(all_data.map((d) -> d.x )))
    @y.domain(d3.extent(all_data.map((d) -> d.y )))
    @x2.domain(@x.domain())
    @y2.domain(@y.domain())


    @focusTarget = @focus.append('rect')
      .attr('class', 'focusTarget')
      .attr('x', 0)
      .attr('y', 0)
      .attr('height', @height)
      .attr('width', @width)
      .style('fill', 'white')
    @focusTarget.call(@zoom)

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
