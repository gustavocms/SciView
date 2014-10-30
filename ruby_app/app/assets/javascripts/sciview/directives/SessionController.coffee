module = angular.module("sv.ui.controllers")

module.controller "SessionController", [
  "$scope"
  "$state"
  "Session"
  "$rootScope"
  ($scope, $state, Session, $rootScope) ->

    Session.requestCurrentUser().then (data)->
      $scope.user = data

    $rootScope.$on('event:authorized', (event, currentUser) ->
      $scope.user = currentUser
    )

    $scope.logout = ->
      Session.logout()
      $state.go('login')
]