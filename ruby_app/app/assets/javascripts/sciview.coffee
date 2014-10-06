# Top-level namespace
window.SciView or= {}
SciView.D3 or= {}
SciView.D3.counter = 0

SciView.lineColor = d3.scale.ordinal().range(value for name, value of {
  'TURQUOISE': '#1ABC9C'
  'SUN FLOWER': '#F1C40F'
  'AMETHYST': '#9B59B6'
  'ORANGE': '#F39C12'
  'EMERALD': '#2ECC71'
  'ALIZARIN': '#E74C3C'
  'SILVER': '#BDC3C7'
  'PETER RIVER': '#3498DB'
  'CARROT': '#E67E22'
  'CLOUDS': '#ECF0F1'
})

class SciView.BasicChart
  constructor: (options = {}) ->
    @initializeBaseVariables(options)


  initializeBaseVariables: (options) ->
    @element = options.element or 'body'
    @margin  = {top: 10, right: 10, bottom: 100, left: 40}
    @margin2 = {top: 430, right: 10, bottom: 20, left: 40}
    @width   = @baseWidth() - @margin.left - @margin.right
    @height  = @baseHeight() - @margin.top - @margin.bottom
    @height2 = @baseHeight() - @margin2.top - @margin2.bottom

  baseWidth: -> 960
  baseHeight: -> 500

noOp = -> # Nothing happens!

class SciView.FocusChart extends SciView.BasicChart
  constructor: (options = {}) ->
    super(options)
    @initializeChartVariables(options)
    @initializeD3Components()
    @initializePleaseWait()
    @initializeSvg()
    @zoom = d3.behavior.zoom()
      .on('zoom', @zoomed)
      .on('zoomend', => @zoomEnd()) # for some reason, it wants this local context binding.
                                    # (does not work without the anonymous wrapper)
    @postInitializeHook()
                                    
  postInitializeHook: noOp

  initializeChartVariables: (options) ->
    @_dataURL     = options.url
    @zoom_options = { startTime: options.startTime, stopTime: options.stopTime, disabledSeries: options.disabledSeries }
    @x            = d3.time.scale().range([0, @width])
    @x2           = d3.time.scale().range([0, @width])
    @y            = d3.scale.linear().range([@height, 0])
    @y2           = d3.scale.linear().range([@height2, 0])
    @xAxis        = d3.svg.axis().scale(@x).orient("bottom")
    @xAxis2       = d3.svg.axis().scale(@x2).orient("bottom")
    @yAxis        = d3.svg.axis().scale(@y).orient("left")

  initializeD3Components: ->
    @brush = d3.svg.brush()
      .x(@x2)
      .on("brush", @brushed)
      .on("brushend", @brushEndDelayed)

    @lineFocus = d3.svg.area()
      .x((d) => @x(d.x))
      .y0(@height)
      .y1((d) => @y(d.y))
      .interpolate('linear')

    @lineContext = d3.svg.line()
      .x((d) => @x2(d.x))
      .y((d) => @y2(d.y))


  initializePleaseWait: ->
    @pleaseWait = d3.select(@element).append('div').attr('id', 'pleaseWait')
    @pleaseWait.append('i')
      .attr('class', 'fa fa-circle-o-notch fa-spin')
    @pleaseWait.append('span').text(' Data loading...')

  # Data loading
  # #################################################
 
  # if argument is present, set data and return self;
  # otherwise return current data
  data: (d, overwrite = false) ->
    if d
      if overwrite or !@_data
        @_data = preprocess(d, @zoom_options['disabledSeries'])
        @isZoomed = false
      else
        # initial data set has already been loaded, and should be kept as the low-fi data set
        @zoomData(d)

      return @
    @_data

  # higher-fidelity data over a narrower domain
  zoomData: (d) ->
    if d
      @_zoomData = preprocess(d, @zoom_options['disabledSeries'])
      @isZoomed = true
      return @
    @_zoomData

  # Trigger the ajax call.
  getData: (retryCount = 0, overwrite = false) ->
    @showPleaseWait()
    get_data_url = "#{@dataURL()}#{@startStopQuery()}&count=960"
    $.ajax({
      url: get_data_url
      success: (response) =>
        @data(response.data, overwrite)
        @render()
        @replaceState(response)
        @hidePleaseWait()
      error: =>
        if retryCount < 6
          setTimeout((=> @getData(retryCount + 1)), 1500)
        else
          @hidePleaseWait()
          msg = "Data could not be retrieved (tried #{retryCount} times). Please check the series names and try again."
          console.log(msg)
    })
  
  showPleaseWait: ->
    @pleaseWait.style('visibility', 'visible')

  hidePleaseWait: ->
    @pleaseWait.style('visibility', 'hidden')

  
  
  disabledSeriesParams: ->
    data = if @isZoomed then @_zoomData else @_data
    disabled_series = data.map((d)-> d.key if d.disabled ).filter( (e)-> return typeof(e) is 'string' )
    if disabled_series.length then "&disabled=#{disabled_series.join(',')}" else ''

  #replace browser history state
  replaceState: (response)->
    window.history.replaceState {}, null, response.permalink + @disabledSeriesParams()

 

  # Stores the data in a renderable format:
  # [ { key: "some key", values: [ { x: 10, y: 20 }, { x: 20, y: 30 } ]} ... ]
  preprocess = (data, disabledSeries) ->
    for _, s of data
      
      disabled = false
      legend = d3.select("#legend_#{s.key}")
      try
        disabled = legend.attr('data-disabled') is 'disabled'
      catch e
        #sometimes this is null need to figure this out
      {
        key: s.key
        values: ( { x: new Date(d.ts), y: d.value } for d in s.values )
        tags: s.tags
        attributes: s.attributes
        disabled: disabled
      }

  dataURL: (string) ->
    if string
      @_dataURL = string
      @options.url = string
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
    @renderObservations()

  brushEnd: =>
    unless @brush.empty()
      @getData()

  # This functions as a single-item queue. If the countdown
  # is already active, it is reset.
  brushEndDelayed: =>
    if @brush.empty()
      @clearTimestamps()
    if @_brushEndTimer
      clearTimeout(@_brushEndTimer)
    @_brushEndTimer = setTimeout((=> @_brushEndTimer = null; @brushEnd()), @brushEndDelayInterval())

  _brushEndDelayInterval: 500

  brushEndDelayInterval: (d) ->
    if d
      @_brushEndDelayInterval = d
      return @
    @_brushEndDelayInterval


  # Zooming and Dragging
  ###############################################

  clearTimestamps: ->
    params = window.location.search.split('&').filter (el)->
      !(/start|stop+_time/.test(el))
    window.history.replaceState({}, null,  params.join('&'))

  zoomEnd: ->
    d3.event.sourceEvent?.stopPropagation()
    if d3.event.sourceEvent?.type is "dblclick"
      return clearTimeout(@_brushEndTimer)
    @zoom.scale(1).translate([0, 0]) # keep movements relative
    @_dx_prev = 0
    @brushEndDelayed()

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
    #<<<<<<< HEAD
    # .attr("width", @width + @margin.left + @margin.right)
    #  .attr("height", @height + @margin.top + @margin.bottom)
    #defs = @svg.append("defs")
    #defs.append("clipPath")
    #  .attr("id", "innerClip")
    #  .append("rect")
    #  .attr("width", @width)
    #  .attr("height", @height)
    #defs.append("clipPath")
    #  .attr("id", "outerClip")
    #  .append("rect")
    #  .attr("width", @width + @margin.left)
    #  .attr("height", @height + @margin.bottom)
    #=======
      .attr("preserveAspectRatio", "none")
    @setSvgAttributes()
    @svg.append("defs").append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("width", @width)
      .attr("height", @height)
    @focus or= @svg.append("g")
      .attr("class", "focus")
      .attr("transform", "translate(" + @margin.left + "," + @margin.top + ")")
    @context or= @svg.append("g")
      .attr("class", "context")
      .attr("transform", "translate(" + @margin2.left + "," + @margin2.top + ")")
  setSvgAttributes: ->
    @svg.attr("width", @width + @margin.left + @margin.right)
    .attr("viewBox", "0 0 #{@width + @margin.right + @margin.left} #{@height + @margin.top + @margin.bottom}")

  #lineColor = d3.scale.category10()
  # lineColor = d3.scale.ordinal().range([
  #   '#8dd3c7'
  #   '#ffffb3'
  #   '#bebada'
  #   '#fb8072'
  #   '#80b1d3'
  #   '#fdb462'
  #   '#b3de69'
  #   '#fccde5'
  #   '#d9d9d9'
  # ])

  lineColor = SciView.lineColor

  render: ->
    if @isZoomed
      @_renderZoomData()
    else
      @_renderInitialData()

  zoomIt: ->
    if @zoom_options['disabledSeries'].length
      for s in @zoom_options['disabledSeries']
        @setSeriesOpacity(s)
    
    if @zoom_options['startTime'] && @zoom_options['stopTime']
      @brush.extent([new Date(1000*@zoom_options['startTime']), new Date(1000*@zoom_options['stopTime'])])
      @context.select('.brush').call(@brush)
      @brushed()
      @brushEnd()

  _renderZoomData: ->
    @focus.selectAll('.init').attr('opacity', 0)
    zoomFocusPaths = @focus.selectAll('path.focus.zoom').data(@_zoomData)
    zoomFocusPaths.enter()
      .append('path')
      .attr('class', 'line focus zoom')
      .attr('id', (d) -> "zoomed_#{d.key}" )
      .style('stroke', (d) -> lineColor(d.key))
      .style('opacity', (d)-> if d.disabled then 0 else 1 )
      .style('fill-opacity', 0.2)
      .style('fill', (d) -> lineColor(d.key))
    zoomFocusPaths.attr('d', (d) => @lineFocus(d.values))
    zoomFocusPaths.exit().remove()

  
  setDomains: ->
    all_data = @_data.map((obj) -> obj.values).reduce((a, b) -> a.concat(b))
    @x.domain(d3.extent(all_data.map((d) -> d.x )))
    @y.domain(d3.extent(all_data.map((d) -> d.y )))
    @x2.domain(@x.domain())
    @y2.domain(@y.domain())

  _renderInitialData: ->
    @setDomains()

    @focusTarget or= @focus.append('rect')
      .attr('class', 'focusTarget')
      .attr('x', 0)
      .attr('y', 0)
      .style('fill', 'black')
      .style('fill-opacity', 0.15)
      .call(@zoom)
    @focusTarget.attr('height', @height)
      .attr('width', @width)
    @observationCursor()

    @focusPaths = @focus.selectAll('path.focus.init').data(@_data)
    @focusPaths.enter()
      .append('path')
      .attr('class', 'line focus init')
      .attr('id', (d) -> d.key )
      .style('stroke', (d) -> lineColor(d.key))
      .style('fill-opacity', 0.2)
      .style('fill', (d) -> lineColor(d.key))
    @focusPaths
      .attr('d', (d) => @lineFocus(d.values))
    @focusPaths.exit().remove()
    @xAxisGroup or= @focus.append("g")
      .attr("class", "x axis")
    @xAxisGroup.attr("transform", "translate(0,#{@height})")
      .call(@xAxis)
    @yAxisGroup or= @focus.append("g")
      .attr("class", "y axis")
    @yAxisMinorGroup or= @focus.append('g')
      .attr('class', 'y axis minor')
    @yAxisGroup.call(@yAxis)
    @yAxisMinorGroup.call(@yAxisMinor) if @yAxisMinor

    contextPaths = @context.selectAll("path.context").data(@_data)
    
    contextPaths.enter()
      .append('path')
      .attr("class", "line context")
    contextPaths
      .attr("d", (d) => @lineContext(d.values))
      .style('stroke', (d) -> lineColor(d.key))
    
    @contextBg or= @context.append("rect")
      .attr('id', 'contextBg')
      .attr('x', 0)
      .attr('width', @width)
      .attr('y', 0)
      .attr('height', @height2)
      .style('fill', 'black')
      .style('fill-opacity', 0.1)
    @xAxisContextGroup or= @context.append("g")
      .attr("class", "x axis")
    @xAxisContextGroup
      .attr("transform", "translate(0," + @height2 + ")")
      .call(@xAxis2)
    @brushGroup or= @context.append("g")
    @brushGroup
      .attr("class", "x brush")
      .call(@brush)
      .selectAll("rect")
      .attr("y", -6)
      .attr("height", @height2 + 7)
    thisChart = @
    @focus.on('mousemove', -> thisChart.observationCursor(d3.mouse(this)))

    x = @x
    obsCallback = @_observationCallback
    @focus.on('dblclick', -> # TODO: does this conflict with the other dblclick (in zoomEnd)?
      observed_at = x.invert(d3.mouse(this)[0])
      obsCallback({ observed_at: observed_at, message: "New message from D3..." })
      d3.event.stopPropagation()
    )

    legend = @svg.selectAll('g.legend').data(@_data)
    legend.enter().append("g").attr("class", "legend").attr('id', (d)-> "legend_#{d.key}")
    @renderLegend()
    @zoomIt()

  renderLegend: ->
    legend = @focusPaths.enter().append("g").attr("class", "legend").attr('id', (d)-> "legend_#{d.key}")
    
    legend.append("rect")
      .attr("x", 20)
      .attr("y", (d, i) -> 20 + i * 20 )
      .attr("width", 10).attr("height", 10).style "fill", (d) -> lineColor(d.key)

    legend.append("text")
      .attr("x", 35)
      .attr("y", (d, i) -> 29 + (i * 20))
      .style('font-weight', 'normal')
      .style('fill', (d) -> lineColor(d.key))
      .style('stroke', 'none')
      .text((d) -> d.key)

    legend.on "click", (d) => @setSeriesOpacity(d.key)

    @renderObservations()
    @zoomIt()

  setSeriesOpacity: (key) =>
    # Determine if current line is visible
    legendElement    = d3.select("#legend_#{key}")
    active           = (if legendElement.attr('active') is "true" then false else true)
    disable          = (if active then 'disabled' else 'enabled')
    newLegendOpacity = (if active then 0.5 else 1)
    newGraphOpacity  = (if active then 0 else 1)
    # Hide or show the elements
    legendElement.style("opacity", newLegendOpacity).attr('data-disabled', disable)
    # Update whether or not the elements are active
    legendElement.attr('active', active)
    d3.select("##{key}").style "opacity", newGraphOpacity
    #@getData()
    d3.select("#zoomed_#{key}").style "opacity", newGraphOpacity

  renderObservations: ->
    #color = (d) -> lineColor(d.series_key) # no longer based on series
    color = 'white'
    groups = @focus.selectAll('g.observation').data(@_observations or [], (d) -> d.id)
    y_height = (_, i) -> (i % 6) * 20 + 20
    gr_enter = groups.enter()
      .append('g')
      .attr('class', 'observation')
    gr_enter
      .append('circle')
      .attr('cx', 0)
      .attr('cy', y_height)
      .attr('r', 3)
      .style('stroke', 'none')
      .style('fill', color)
    gr_enter
      .append('line').attr('x1', 0).attr('x2', 0).attr('y1', 10).attr('y2', @height)
      .attr('class', 'observation-line')
      .style('stroke', color)
      .attr('stroke-dasharray', '1,3')
    text = gr_enter
      .append('text')
      .text((d) -> d.message)
      .attr('x', 5).attr('y', y_height)
      .style('fill', color)
      .style('font-weight', 'bold')
      .style('font-size', '8pt')
    groups.attr('transform', (d) => "translate(#{@x(new Date(d.observed_at))}, 0)")
    groups.exit().remove()

  observationCursor: (coords) ->
    x = (coords or [0])[0]
    @focusCursor or= @focus.append('line').attr('id', 'focusCursor')
      .style('opacity', 0.5)
      .style('stroke', 'white')
      .attr('y1', 0)
      .attr('y2', @height)

    @contextCursor or= @context.append('line').attr('id', 'contextCursor')
      .style('opacity', 0.5)
      .style('stroke', 'white')
      .attr('y1', 0).attr('y2', @height2)

    x2 = @x2(@x.invert(x))
    @focusCursor.attr('x1', x).attr('x2', x)
    @contextCursor.attr('x1', x2).attr('x2', x2)

    @focusIntersects or= @focus.append('g').attr('class', 'focusIntercepts')
    circles = @focusIntersects.selectAll('circle').data(@_focusPathIntersections(x))
    circles.enter()
      .append('circle')
      .attr('r', 4)
      .style('fill', (d) -> lineColor(d.key))
      .style('stroke', 'none')

    circles.attr('cx', x)
    circles.attr('cy', (d) -> d.position.y)
    circles.exit().remove()

  _focusPathIntersection = (x_coord, path) ->
    node       = path
    target     = undefined
    pos        = undefined
    end        = node.getTotalLength()
    x          = x_coord
    beginning  = x

    while (true)
      target = Math.floor((beginning + end) / 2)
      pos    = node.getPointAtLength(target)
      break if ((target is end or target is beginning) and pos.x isnt x)
      if (pos.x > x)
        end = target
      else if (pos.x < x)
        beginning = target
      else
        break #position found
    { position: pos, key: node.__data__.key }


  _focusPathIntersections: (x_coord) =>
    #try
    selector = if @isZoomed then 'path.focus.zoom' else 'path.focus.init'
    paths = @focus.selectAll(selector)[0]
    _focusPathIntersection(x_coord, path) for path in paths
    #catch
    #[]


# subclassing the chart for the Angular app (so the basic html app doesn't break)
class SciView.D3.FocusChart extends SciView.FocusChart
  
  # TODO - move 'data loading' indicator elsewhere
  initializePleaseWait: noOp
  showPleaseWait:       noOp
  hidePleaseWait:       noOp
  renderLegend:         noOp
  replaceState:         noOp
  _observationCallback: noOp

  elementSelection: -> @_elementSelection or= d3.select(@element)

  constructor: (options) ->
    @options = options
    super(options)

  initializeBaseVariables: (options) ->
    @chart_uuid = options.chart_uuid
    @element    = options.element or 'body'
    bh = @baseHeight()
    h1 = bh * 0.85
    h2 = bh - h1
    @margin  = {top: 0, right: 0, bottom: h2 + 10, left: 0}
    @margin2 = {top: h1 + 10, right: 0, bottom: 0, left: 0}
    @width   = @baseWidth() - @margin.left - @margin.right
    @height  = @baseHeight() - @margin.top - @margin.bottom
    @height2 = @baseHeight() - @margin2.top - @margin2.bottom

  initializeChartVariables: (options) ->
    @_dataURL     = options.url
    @zoom_options = { startTime: options.startTime, stopTime: options.stopTime, disabledSeries: (options.disabledSeries or []) }
    @x            = d3.time.scale().range([0, @width])
    @x2           = d3.time.scale().range([0, @width])
    @y            = d3.scale.linear().range([@height, 0])
    @y2           = d3.scale.linear().range([@height2, 0])
    @xAxis        = d3.svg.axis().scale(@x).orient("bottom")
    @xAxis2       = d3.svg.axis().scale(@x2).orient("bottom")
    @yAxis        = d3.svg.axis()
      .scale(@y)
      .orient("right")
      .tickFormat(d3.format(".0f"))
      .ticks(10)
      .tickSize(20, 10)
    @yAxisMinor = d3.svg.axis()
      .scale(@y)
      .orient("right")
      .tickFormat("")
      .ticks((@y.ticks(10).length + 1) * 4)
      .tickSize(20, 10)

  baseWidth: ->
    parseInt(@elementSelection().style('width'))

  baseHeight: ->
    parseInt(@elementSelection().style('height'))

  # re-scales the chart based on the new dimensions of the chart's container
  redraw: =>
    # only if initial data set has already been loaded
    if @_data
      @initializeBaseVariables(@options)
      @initializeChartVariables(@options)
      @initializeD3Components()
      @setSvgAttributes()
      @render()

  observationCallback: (callback_function) ->
    if callback_function
      @_observationCallback = callback_function
      return @
    else
      @_observationCallback

  observations: (observations) ->
    if observations
      @_observations = observations
      @renderObservations()
      return @
    else
      @_observations

