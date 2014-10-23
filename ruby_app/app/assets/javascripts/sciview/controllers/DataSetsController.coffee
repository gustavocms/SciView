module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  'ViewState'
  'data_sets'
  ($scope, ViewState, data_sets) ->

    $scope.data_sets = data_sets

    $scope.newDataSet = ->
      ViewState.save({})
      .$promise
      .then((raw) ->
        dataset = SciView.Models.ViewState.deserialize(raw)
        $scope.data_sets.push(dataset)
        $scope.$state.go('data-sets.single', { dataSetId: dataset.id })
      )
])
