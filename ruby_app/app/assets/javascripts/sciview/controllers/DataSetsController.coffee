module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  'ViewState'
  'data_sets'
  ($scope, ViewState, data_sets) ->

    $scope.edit = false

    $scope.data_sets = data_sets

    $scope.newDataSet = ->
      ViewState.create({})
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
      $scope.edit_data_set = data_set
      $scope.edit = true

    $scope.hideEdit = ->
      $scope.edit_data_set = {}
      $scope.edit = false

    $scope.saveEdit = ->
      $scope.edit_data_set = {}
      $scope.edit = false

    $scope.deleteDataSet = ->
      # Flash modal confirming delete
      # Delete after confirmation

])
