app = angular.module('sciview')

app.controller('NewDataSetController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->
    $scope.newDataSet = ->
      ViewState.save({})
        .$promise
        .then((data) ->
          $scope.$state.go('data-sets.single', { dataSetId: data.id })
        )

])
