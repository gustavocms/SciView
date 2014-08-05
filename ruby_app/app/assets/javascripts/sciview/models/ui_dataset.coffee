window.SciView or= {}
SciView.Models or= {}


class SciView.Models.UISeries
  constructor: (@title, @category, @key) ->




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



class SciView.Models.UIDataset
  constructor: (@id, @title) ->
    @charts = []

  addChart: ->
    @charts.push(@_newChart())

  _newChart: -> new SciView.Models.UIChart("Untitled Chart")

  removeChart: -> # TODO

