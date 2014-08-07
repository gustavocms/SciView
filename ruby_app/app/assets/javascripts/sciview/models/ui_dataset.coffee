window.SciView or= {}
SciView.Models or= {}

class SciView.Models.UIBase
  # assigns a property is arg is present and defined, otherwise
  # defaults to the function on _defaults with the same property name
  default: (attr, arg) ->
    @[attr] = ( arg or (@_defaults[attr] or @_noOp)())

  _defaults:
    title: -> "untitled"

  _noOp: ->

  afterDeserialize: ->

  # javascript primitives that don't need additional serialization
  @serialized_attributes: []

  # collections of objects that have their own serialization functions
  @serializable_collections: []

  @deserialize: (obj) ->
    newObj = new @()
    newObj.default(key, obj[key]) for key in @serialized_attributes
    for key, klass of @serializable_collections
      newObj[key] = (klass.deserialize(member) for member in obj[key])
    newObj.afterDeserialize()
    newObj

  serialize: ->
    serialized = {}
    (serialized[key] = @[key]) for key in @constructor.serialized_attributes
    for key, klass of @constructor.serializable_collections
      serialized[key] = (member.serialize() for member in @[key])
    serialized



class SciView.Models.UISeries extends SciView.Models.UIBase
  constructor: (@title, @category) ->
    @key = @default('key')

  seriesKeys: -> [@title]

  _defaults:
    key: -> { color: SciView.lineColor(@title), style: "solid" }
    title: -> "untitled series"

  @serialized_attributes: ['title', 'category', 'key']


class SciView.Models.UIChannel extends SciView.Models.UIBase
  constructor: (@title) ->
    @default('state')
    @default('series')
    #@group = [new SciView.Models.UISeries('default', 'default category')]

  seriesKeys: ->
    series.title for series in @series

  @serialized_attributes: ['title', 'state']
  @serializable_collections:
    series: SciView.Models.UISeries

  _defaults:
    title: -> "Untitled Chart"
    state: -> "retracted"
    series: -> []

  _state: (state) ->
    @state = state
    @

  expand: -> @_state('expanded')
  retract: -> @_state('retracted')


# UIChart provides an interface to the D3 chart and stores
# references to channels/series.
class SciView.Models.UIChart extends SciView.Models.UIBase
  constructor: (@title) ->
    # default channel holds otherwise ungrouped series.
    # TODO: is there a better way to reference this rather
    # than just keeping it at channels[0]? (brittle)
    @channels = [new SciView.Models.UIChannel('default channel').expand()]
    @_computeDataUrl()
    #@initializeChart()

  #chart: "assets/graph_1.svg" # TODO - replace this

  initializeChart: (element) ->
    @chart = new SciView.D3.FocusChart(
      element: element
      url: @dataUrl
    )

  addChannel: (channel) ->
    if channel
      @channels.push(channel)
    else
      undefined # TODO - insert channel template
    @_computeDataUrl()

  removeChannel: -> # TODO
  addGroup: -> # TODO
  removeGroup: -> # TODO

  addSeries: (series_title, load_data = true) -> # load_data switch facilitates testing
    @channels[0].series.push(new SciView.Models.UISeries(series_title, "default category"))
    @refresh() if load_data

  dataUrl: "--"

  refresh: ->
    @chart or @initializeChart()
    @_computeDataUrl()
    @chart.dataURL(@dataUrl).getData()

  _computeDataUrl: ->
    @dataUrl = "/api/v1/datasets/multiple?#{@_seriesQueryString()}"

  _seriesQueryString: ->
    ("series_#{i}=#{k}" for k, i in @_allSeriesKeys()).join("&")

  _allSeriesKeys: ->
    seriesKeys = []
    for channel in @channels
      seriesKeys.push(key) for key in channel.seriesKeys()
    return seriesKeys

  @serialized_attributes: ['title']
  @serializable_collections:
    channels: SciView.Models.UIChannel

  afterDeserialize: -> @_computeDataUrl()

class SciView.Models.UIDataset extends SciView.Models.UIBase
  constructor: (@id, @title) ->
    @charts = []

  addChart: -> @charts.push(@_newChart())

  _newChart: -> new SciView.Models.UIChart("Untitled Chart")

  removeChart: -> # TODO

  # Triggers a data load/d3 redraw
  refresh: -> 
    console.log(@charts)
    chart.refresh() for chart in @charts

  @serialized_attributes: ['id', 'title']
  @serializable_collections:
    charts: SciView.Models.UIChart

