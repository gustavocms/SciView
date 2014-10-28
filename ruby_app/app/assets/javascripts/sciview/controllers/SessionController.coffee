module = angular.module("sv.ui.controllers")

module.controller "SessionController", [
  "$scope"
  "$state"
  "Session"
  ($scope, $state, Session) ->

    Session.requestCurrentUser().then (data)->
      $scope.user = data

    $scope.logout = ->
      Session.logout()
      $state.go('login')
]