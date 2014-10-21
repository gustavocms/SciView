module = angular.module("sv.ui.controllers")

module.controller "NavigatorController", [
  "$scope"
  "$q"
  "Sources"
  "ViewState"
  ($scope, $q, Sources, ViewState) ->
    $scope.navigator = search_query: ""

    $scope.deferredDatasetsLoading = $q.defer()
    $scope.data_sets = []

    ViewState.index()
      .$promise
      .then((data) ->
        $scope.data_sets = (SciView.Models.ViewState.deserialize(raw) for raw in data)
        $scope.deferredDatasetsLoading.resolve()
        console.log($scope.data_sets)
      )
]
