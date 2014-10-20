module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  '$q'
  '$state'
  'ViewState'
  'Alerts'
  ($scope, $q, $state, ViewState, Alerts) ->

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

    $scope.mouseEnterTitle = (data_set, scope) ->
      currentDataSet = parseInt($state.params.dataSetId)
      selectedDataSetId = data_set.id
      if `currentDataSet == selectedDataSetId`
        data_set.hover = true

    $scope.mouseLeaveTitle = (data_set) ->
      data_set.hover = false

    $scope.editDataSet = (data_set) ->
      data_set.edit = true

])
