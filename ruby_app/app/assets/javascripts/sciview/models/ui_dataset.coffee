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

  # javascript primitives that don't need additional serialization
  @serialized_attributes: []

  # collections of objects that have their own serialization functions
  @serializable_collections: []

  @deserialize: (obj) ->
    newObj = new @()
    newObj.default(key, obj[key]) for key in @serialized_attributes
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
    @state = 'retracted'
    #@group = [new SciView.Models.UISeries('default', 'default category')]
    @series = []

  seriesKeys: ->
    series.title for series in @series

  @serialized_attributes: ['title']
  @serializable_collections:
    series: SciView.Models.UISeries


class SciView.Models.UIChart
  constructor: (@title) ->
    @channels = []
    @_computeDataUrl()
    #@initializeChart()

  chart: "assets/graph_1.svg" # TODO - replace this

  initializeChart: (element) ->
    @chart = new SciView.FocusChart(
      element: element
      url: @dataUrl
    )

  addChannel: -> # TODO
  removeChannel: -> # TODO
  addGroup: -> # TODO
  removeGroup: -> # TODO

  addSeries: (series_title) ->
    @channels.push(new SciView.Models.UISeries(series_title, "default category"))
    @_computeDataUrl()
    @chart.dataURL(@dataUrl).getData()

  dataUrl: "--"

  _computeDataUrl: ->
    @dataUrl = "/api/v1/datasets/multiple?#{@_seriesQueryString()}"

  _seriesQueryString: ->
    ("series_#{i}=#{k}" for k, i in @_allSeriesKeys()).join("&")

  _allSeriesKeys: ->
    seriesKeys = []
    for channel in @channels
      seriesKeys.push(key) for key in channel.seriesKeys()
    return seriesKeys

  serialize: ->
    title: @title
    channels: @channels
    # TODO: UISeries needs a serializer
    # class for UIChannel

  @deserialize: (obj) ->
    chart = new @()
    chart.channels = obj.channels if obj.channels

class SciView.Models.UIDataset
  constructor: (@id, @title) ->
    @charts = []

  addChart: ->
    @charts.push(@_newChart())

  _newChart: -> new SciView.Models.UIChart("Untitled Chart")

  removeChart: -> # TODO

  serialize: ->
    id:    @id
    title: @title
    charts: (chart.serialize() for chart in @charts)

  @deserialize: (obj) ->
    dataset = new @(obj.id, obj.title)
    dataset.charts = (SciView.Models.UIChart.deserialize(chart) for chart in (obj.charts or []))
    return dataset
