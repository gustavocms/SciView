
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
      .on("brushstart", @brushStart)


    @lineFocus = d3.svg.line()
      .x((d) => @x(d.x))
      .y((d) => @y(d.y))

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
      @_data = preprocess(d)
      return @
    @_data

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

  loadCSVData: (filepath) =>
    d3.csv(filepath, @type, (error, data) =>
      @data(data)
      @render()
    )

  # Brushing functions
  ########################################

  brushed: =>
    @x.domain(if @brush.empty() then @x2.domain() else @brush.extent())
    @focus.selectAll(".line.focus").attr("d", (d) => @lineFocus(d.values))
    @focus.select(".x.axis").call(@xAxis)
    console.log('brushed')

  brushEnd: =>
    # load new data
    console.log("brushEnd")

  brushStart: =>
    # probably don't need this
    console.log("brushStart")


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

  render: ->
    all_data = @data().reduce (a, b) -> a.values.concat b.values

    @x.domain(d3.extent(all_data.map((d) -> d.x )))
    @y.domain(d3.extent(all_data.map((d) -> d.y )))
    @x2.domain(@x.domain())
    @y2.domain(@y.domain())

    focusPaths = @focus.selectAll('path.focus').data(@_data)
    focusPaths.enter()
      .append('path')
      .attr('class', 'line focus')
      .attr('d', (d) => @lineFocus(d.values))
      .attr("clip-path", "url(#clip)")
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

