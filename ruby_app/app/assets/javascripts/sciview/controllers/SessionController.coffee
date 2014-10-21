module = angular.module("sv.ui.controllers")

module.controller "SessionController", [
  "$scope"
  "Session"
  ($scope, Session) ->

    Session.requestCurrentUser().then (data)->
      $scope.user = data

    $scope.logout = ->
      Session.logout()

]