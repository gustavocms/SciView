app = angular.module('sciview')

app.controller('DataSetsController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->
    # Get all Data Sets
    $scope.data_sets = []
    ViewState.index()
      .$promise
      .then((data) ->
        $scope.data_sets = data
      )
])
