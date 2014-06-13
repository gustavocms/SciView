
# Top-level namespace
window.SciView = {}

class SciView.BasicChart
  constructor: (element = 'body') ->
    @element = element
    @margin  = {top: 10, right: 10, bottom: 100, left: 40}
    @margin2 = {top: 430, right: 10, bottom: 20, left: 40}
    @width   = 960 - @margin.left - @margin.right
    @height  = 500 - @margin.top - @margin.bottom
    @height2 = 500 - @margin2.top - @margin2.bottom

  # if argument is present, set data and return self;
  # otherwise return current data
  data: (d) ->
    if d
      console.log('chart data!')
      @_data = d
      return @
    @_data


class SciView.FocusChart extends SciView.BasicChart
  constructor: (element) ->
    super(element)
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
    @lineFocus = d3.svg.line()
      .interpolate("monotone")
      .x((d) => @x(d.x))
      .y((d) => @y(d.y))

    @lineContext = @lineFocus

    @initializeSvg()

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

  brushed: =>
    @x.domain(if @brush.empty() then @x2.domain() else @brush.extent())
    @focus.select(".line.focus").attr("d", @lineFocus)
    @focus.select(".x.axis").call(@xAxis)

  type: (d) -> { x: new Date(d.ts), y: d.value }

  render: ->
    key = Object.keys(@_data)[0]
    values = @_data[key].values # TODO: this is hard-coded for testing purposes
    data = (@type(e) for e in values)
    window.data = data

    @x.domain(d3.extent(data.map((d) -> d.x )))
    @y.domain(d3.extent(data.map((d) -> d.y )))
    @x2.domain(@x.domain())
    @y2.domain(@y.domain())

    @focus.append("path")
      .datum(data)
      .attr("class", "line focus")
      .attr("d", @lineFocus)
      .attr("clip-path", "url(#clip)")

    @focus.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + @height + ")")
      .call(@xAxis)

    @focus.append("g")
      .attr("class", "y axis")
      .call(@yAxis)

    @context.append("path")
      .datum(data)
      .attr("class", "line context")
      .attr("d", @lineContext)

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



  loadCSVData: (filepath) =>
    d3.csv(filepath, @type, (error, data) =>
      @data(data)
      @render()
    )
