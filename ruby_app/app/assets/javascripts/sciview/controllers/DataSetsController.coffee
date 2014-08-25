app = angular.module('sciview')

app.controller('DataSetsController', [
  '$scope'
  'ViewState'
  ($scope, ViewState) ->

    $scope.data_sets = []

    ViewState.index()
      .$promise
      .then((data) ->
        for raw in data
          do (raw) ->
            dataset = SciView.Models.UIDataset.deserialize(raw)
            $scope.data_sets.push(dataset)
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
