window.SciView or= {}
SciView.Models or= {}


class SciView.Models.UISeries
  constructor: (@title, @category) ->
    @key = { color: SciView.lineColor(@title), style: "solid" }

class SciView.Models.UIChart
  constructor: (@title) ->
    @channels = [
      { title: 'Default Channel', state: 'retracted', group: [{}] }
    ]

  chart: "assets/graph_1.svg" # TODO - replace this

  addChannel: -> # TODO
  removeChannel: -> # TODO
  addGroup: -> # TODO
  removeGroup: -> # TODO

  addSeries: (series_title) ->
    @channels.push(new SciView.Models.UISeries(series_title, "default category"))



class SciView.Models.UIDataset
  constructor: (@id, @title) ->
    @charts = []

  addChart: ->
    @charts.push(@_newChart())

  _newChart: -> new SciView.Models.UIChart("Untitled Chart")

  removeChart: -> # TODO

