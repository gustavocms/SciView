app = angular.module('sciview')

app.controller('NewDataSetController', [
  '$scope'
  '$rootScope'
  '$location'
  '$stateParams'
  '$state'
  'DataSets'
  'ViewState'
  ($scope, $rootScope, $location, $stateParams, $state, DataSets, ViewState) ->
    $scope.newDataSet = ->
      ViewState.save({})
        .$promise
        .then((data) ->
          window.l = $location
          window.s = $state
          window.sp = $stateParams
          $state.go('data-sets.single', { dataSetId: data.id })
        )

])
