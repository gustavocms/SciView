app.controller('DataSetController', [
  '$scope'
  '$rootScope'
  '$location'
  '$stateParams'
  '$state'
  'DataSets'
  ($scope, $rootScope, $location, $stateParams, $state, DataSets)  ->
    # Get all Data Sets        
    $scope.data_sets = DataSets.getDataSets()

    setCurrentDataSet = () -> $scope.current_data_set = $scope.data_sets[$stateParams.dataSetId]
    setCurrentDataSet()

    # Make $state available in $scope
    $scope.$state = $state

    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = -> @current_data_set.addChart()

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "retracted" then "expanded" else "retracted")
])
