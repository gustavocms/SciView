module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  '$q'
  'ViewState'
  'Alerts'
  ($scope, $q, ViewState, Alerts) ->

#   deferred promise needed for the child state to wait for
    $scope.deferredDatasetsLoading = $q.defer()

    $scope.data_sets = []

    ViewState.index()
      .$promise
      .then((data) ->
        $scope.data_sets = (SciView.Models.ViewState.deserialize(raw) for raw in data)
        $scope.deferredDatasetsLoading.resolve()
      )

    $scope.newDataSet = ->
      ViewState.save({})
      .$promise
      .then((raw) ->
        dataset = SciView.Models.ViewState.deserialize(raw)
        $scope.data_sets.push(dataset)
        $scope.$state.go('data-sets.single', { dataSetId: dataset.id })
      )

    $scope.editDataSet = (data_set) ->
      data_set.editing = true
      Alerts.pushMessage("Rename Data Set", "neutral")

])
