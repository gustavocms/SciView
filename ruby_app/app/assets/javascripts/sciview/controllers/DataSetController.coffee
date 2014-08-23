app = angular.module('sciview')

app.controller('DataSetController', [
  '$scope'
  '$stateParams'
  '$state'
  'DataSets'
  'ViewState'
  ($scope, $stateParams, $state, DataSets, ViewState) ->
    setCurrentDataSet = (dataset) ->
      $scope.current_data_set = dataset

    deserializeAndSetCurrent = (raw) ->
      dataset = SciView.Models.UIDataset.deserialize(raw)
      $scope.resource = raw
      setCurrentDataSet(dataset)

    ViewState.get({ id: $stateParams.dataSetId }, deserializeAndSetCurrent) if $stateParams.dataSetId?

    # Make $state available in $scope
    $scope.$state = $state
    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = ->
      @current_data_set.addChart()

    $scope.logDataset = ->
      console.log(@current_data_set)
      console.log(angular.toJson(@current_data_set.serialize()))

    $scope.saveDataset = ->
      ViewState.update(
        { id: $scope.current_data_set.id },
        $scope.current_data_set.serialize()
      )

    $scope.deleteDataset = ->
      dataset_id = $scope.current_data_set.id
      ViewState.delete({ id: dataset_id })
        .$promise
        .then(->
          $scope.data_sets = $scope.data_sets.filter((ds) -> ds.id isnt dataset_id)
          $state.go('data-sets')
        )

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")
])
