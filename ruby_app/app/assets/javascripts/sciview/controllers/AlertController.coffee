module = angular.module("sv.ui.controllers")

module.controller('AlertController', [
  '$scope'
  '$q'
  '$timeout'
  'ViewState'
  'Alerts'
  ($scope, $q, $timeout, ViewState, Alerts) ->
    $scope.message = {}

    $scope.$on('alert', (event, data) -> 
      $scope.message_hide = false
      $scope.message = data
      $timeout ( ->
        $scope.message_hide = true
        return
      ), 3000    
    )
])
