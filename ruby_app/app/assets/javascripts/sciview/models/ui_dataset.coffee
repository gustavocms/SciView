window.SciView or= {}
SciView.Models or= {}

class SciView.Models.UISeries
  constructor: (@title, @category) ->
    @key = { color: SciView.lineColor(@title), style: "solid" }

  seriesKeys: -> [@title]

class SciView.Models.UIChannel
  constructor: (@title) ->
    @state = 'retracted'
    @group = [new SciView.Models.UISeries('default', 'default category')]

  seriesKeys: ->
    series.title for series in @group


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
