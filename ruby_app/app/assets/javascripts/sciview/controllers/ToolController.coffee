module = angular.module("sv.ui.controllers")

module.controller "ToolController", [
  "$scope"
  ($scope) ->
    ### TODO: this doesn't work
    $scope.$parent.onCursor or= []
    _digest = -> console.log('scope digest'); $scope.$digest()
    $scope.$parent.onCursor.push($scope.$digest)
    ###
    #window.ts = $scope

]
