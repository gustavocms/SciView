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
    @channels = [
      new SciView.Models.UIChannel('default channel')
    ]



  chart: "assets/graph_1.svg" # TODO - replace this

  initializeChart: (element) ->
    @chart = new SciView.FocusChart(
      element: element
      url: 'default-url'
    )

  addChannel: -> # TODO
  removeChannel: -> # TODO
  addGroup: -> # TODO
  removeGroup: -> # TODO

  addSeries: (series_title) ->
    @channels.push(new SciView.Models.UISeries(series_title, "default category"))
    @_computeDataUrl()

  dataUrl: "--"

  _computeDataUrl: -> @dataUrl = @_allSeriesKeys()

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
