module = angular.module("sv.ui.controllers")

module.controller "AddSeriesController", [
  "$scope"
  ($scope) ->
    $scope.is_adding = false
    $scope.placeholder = "Add Series"

    $scope.cancel = ->
      $scope.is_adding = false
      $scope.new_series_title = ""
      $scope.placeholder = "Add Series"

    $scope.adding = ->
      $scope.is_adding = true

    $scope.focus = ->
      $scope.placeholder = "Search key, tag or attribute"

]
