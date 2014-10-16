module = angular.module("sv.ui.controllers")

module.controller "UserController", [
  "$scope"
  "Session"
  ($scope, Session) ->
    "use strict"
    $scope.login = (user) ->
      $scope.authError = null
      Session.login(user.email, user.password).then ((response) ->
        unless response
          $scope.authError = "Credentials are not valid"
        else
          $scope.authError = "Success!"
      ), (response) ->
        $scope.authError = response.data.error

    $scope.logout = ->
      Session.logout()

    $scope.register = (user) ->
      $scope.authError = null
      Session.register(user.email, user.password, user.confirm_password).then ((response) ->
        console.log response
      ), (response) ->
        errors = ""
        $.each response.data.errors, (index, value) ->
          errors += index.substr(0, 1).toUpperCase() + index.substr(1) + " " + value + ""

        $scope.authError = errors
]