app.controller('DataSetController', [
  '$scope'
  '$stateParams'
  'ViewState'
  ($scope, $stateParams, ViewState) ->

    setCurrentDataSet = (dataset) ->
      $scope.current_data_set = dataset

    deserializeAndSetCurrent = (raw) ->
      dataset = SciView.Models.UIDataset.deserialize(raw)
      setCurrentDataSet(dataset)

    ViewState.get({ viewStateId: $stateParams.dataSetId }, deserializeAndSetCurrent) if $stateParams.dataSetId?

    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = -> @current_data_set.addChart()
    $scope.logDataset = ->
      console.log(@current_data_set)
      console.log(angular.toJson(@current_data_set.serialize()))

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")
])
