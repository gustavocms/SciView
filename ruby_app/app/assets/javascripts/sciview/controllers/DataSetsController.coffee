module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  '$q'
  'ViewState'
  ($scope, $q, ViewState) ->

#   deferred promise needed for the child state to wait for
    $scope.deferredDatasetsLoading = $q.defer()

    $scope.data_sets = []

    ViewState.index()
      .$promise
      .then((data) ->
        for raw in data
          do (raw) ->
            dataset = SciView.Models.UIDataset.deserialize(raw)
            $scope.data_sets.push(dataset)

        $scope.deferredDatasetsLoading.resolve()
      )

    $scope.newDataSet = ->
      ViewState.save({})
      .$promise
      .then((raw) ->
        dataset = SciView.Models.UIDataset.deserialize(raw)
        $scope.data_sets.push(dataset)
        $scope.$state.go('data-sets.single', { dataSetId: dataset.id })
      )
])
