module = angular.module("sv.ui.controllers")

module.controller "SessionController", [
  "$scope"
  "Session"
  ($scope, Session) ->

    $scope.user = Session.requestCurrentUser();

    $scope.logout = ->
      Session.logout()

]