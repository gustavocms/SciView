app = angular.module('sciview')

app.controller('DataSetsController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->
    $scope.data_sets = []
    ViewState.index()
      .$promise
      .then((data) -> $scope.data_sets = data)
])
