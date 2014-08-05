window.SciView or= {}
SciView.Models or= {}

class SciView.Models.Dataset
  constructor: (@id, @title) ->
    @batches = []

  addBatch: ->
    @batches.push(@_newBatch())

  _newBatch: -> { title: "Untitled Batch", chart: "assets/graph_1.svg", channel: [] }


