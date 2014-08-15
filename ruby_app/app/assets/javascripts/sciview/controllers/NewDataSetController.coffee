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
        .then((data) -> console.log(data))

])
