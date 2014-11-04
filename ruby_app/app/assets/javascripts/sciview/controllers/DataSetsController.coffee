module = angular.module("sv.ui.controllers")

module.controller('DataSetsController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->

    $scope.states =
      is_editing: false

    $scope.$watch(
      ->
        ViewState.lastModified
      ->
        ViewState.findAll().then (data) ->
          $scope.data_sets = (SciView.Models.ViewState.deserialize(raw) for raw in data)
    )

    $scope.newDataSet = ->
      ViewState.create({})
      .then((raw) ->
        dataset = SciView.Models.ViewState.deserialize(raw)
        $scope.data_sets.push(dataset)
        $scope.$state.go('data-sets.single', { dataSetId: dataset.id })
      )

    $scope.mouseEnterTitle = (data_set) ->
      currentDataSet = parseInt($scope.$state.params.dataSetId)
      selectedDataSetId = data_set.id
      if currentDataSet == selectedDataSetId
        data_set.hover = true

    $scope.mouseLeaveTitle = (data_set) ->
      data_set.hover = false

    $scope.editDataSet = (data_set) ->
      $scope.edit_data_set =
        title: data_set.title
        data_set: data_set
      $scope.states.is_editing = true

    $scope.hideEdit = ->
      $scope.edit_data_set = {}
      $scope.states.is_editing = false

    $scope.saveEdit = ->
      $scope.edit_data_set.data_set.title = $scope.edit_data_set.title
      saveDataset($scope.edit_data_set.data_set)
      $scope.edit_data_set = {}
      $scope.states.is_editing = false

    $scope.deleteDataSet = (data_set) ->
      # Flash modal confirming delete
      # Delete after confirmation

    saveDataset = (data_set) ->
      ViewState.update(
        data_set.id,
        data_set.serialize()
      )
      console.log('saving')

])
