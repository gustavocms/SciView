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

    setCurrentDataSet = () -> $scope.current_data_set = $scope.data_sets[$stateParams.dataSetId] # TODO: fixme
    setCurrentDataSet()

    window.v = ViewState
    req = ViewState.get({ viewStateId: 1 })
    req.$promise
      .then((data) ->
        $scope.data_sets = (SciView.Models.UIDataset.deserialize(d) for d in [data])
        $scope.current_data_set = $scope.data_sets[0]
      )

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
