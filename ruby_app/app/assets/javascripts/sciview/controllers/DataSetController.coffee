app.controller('DataSetController', [
  '$scope'
  '$rootScope'
  '$location'
  '$stateParams'
  '$state'
  'DataSets'
  'ViewState'
  ($scope, $rootScope, $location, $stateParams, $state, DataSets, ViewState) ->
    # Get all Data Sets        
    #$scope.data_sets = DataSets.getDataSets()
    $scope.data_sets = []

    setCurrentDataSet = (dataset) ->
      dataset or= $scope.data_sets[$stateParams.dataSetId] # TODO: fixme (shouldn't be array-indexed)
      $scope.current_data_set = dataset

    #setCurrentDataSet()

    deserializeAndSetCurrent = (raw) ->
      dataset = SciView.Models.UIDataset.deserialize(raw)
      $scope.data_sets.push(dataset) # TODO: does this controller need to know about this array?
      $scope.resource = raw
      setCurrentDataSet(dataset)

    ViewState.get({ id: $stateParams.dataSetId })
      .$promise
      .then(deserializeAndSetCurrent)

    ViewState.index()
      .$promise
      .then((data) ->
        $scope.data_sets = data
        console.log(data)
      )

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
          window.s = $scope
          $state.go('data-sets')
        )

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")

])
