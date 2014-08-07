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
      $scope.data_sets.push(dataset)
      setCurrentDataSet(dataset)

    ViewState.get({ viewStateId: 1 }).$promise.then(deserializeAndSetCurrent) # TODO: should not have a hard-coded id

    # Make $state available in $scope
    $scope.$state = $state

    window.s = $scope
    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = -> @current_data_set.addChart()
    $scope.logDataset = ->
      console.log(@current_data_set)
      console.log(angular.toJson(@current_data_set.serialize()))

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "retracted" then "expanded" else "retracted")

])
