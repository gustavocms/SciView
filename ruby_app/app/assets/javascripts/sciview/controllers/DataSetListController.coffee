app = angular.module('sciview')

app.controller('DataSetListController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->
    # Get all Data Sets
    $scope.data_sets = ViewState.query()
])
