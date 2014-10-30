module = angular.module('sv.ui.services')

module.factory "Session", [
  "$window", "$http", "$q",
  ($window, $http, $q) ->

    # Redirect to the given url (defaults to '/')
    reloadingRedirect = (destination) ->
      $window.location.href = destination
      $window.location.reload()

    service =
      login: (email, password) ->
        $http.post("/api/v1/sessions",
          user:
            email: email
            password: password
        ).then (response) ->
          service.currentUser = response.data.user
          reloadingRedirect('/ng#/data-sets') if service.isAuthenticated()

      logout: () ->
        $http.delete('/api/v1/sessions').then (response) ->
          $http.defaults.headers.common['X-CSRF-Token'] = response.data.csrfToken
          service.currentUser = null
          reloadingRedirect('/ng#/login')

      register: (email, password, confirm_password) ->
        $http.post("/api/v1/users",
          user:
            email: email
            password: password
            password_confirmation: confirm_password
        ).then (response) ->
          service.currentUser = response.data
          reloadingRedirect('/ng#/data-sets') if service.isAuthenticated()

      requestCurrentUser: ->
        if service.isAuthenticated()
          $q.when service.currentUser
        else
          $http.get("/api/v1/users").then (response) ->
            service.currentUser = response.data.user
            service.currentUser

      currentUser: null
      isAuthenticated: ->
        !!service.currentUser

    service
]