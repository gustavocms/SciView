module = angular.module("sv.ui.controllers")

module.controller "SessionController", [
  "$scope"
  "$state"
  "Session"
  "$rootScope"
  ($scope, $state, Session, $rootScope) ->

    Session.requestCurrentUser().then (data)->
      $scope.user = data
      $scope.isAuthenticated = Session.isAuthenticated()

    $rootScope.$on('event:authorized', (event, currentUser) ->
      $scope.user = currentUser
      $scope.isAuthenticated = true
    )

    $scope.logout = ->
      Session.logout()
      $scope.isAuthenticated = false
      $state.go('login')
]