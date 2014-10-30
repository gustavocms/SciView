module = angular.module('sv.ui.services')

module.factory "Session", [
  "$state", "$http", "$q", "$rootScope"
  ($state, $http, $q, $rootScope) ->

    service =
      login: (email, password) ->
        $http.post("/api/v1/sessions",
          user:
            email: email
            password: password
        ).then (response) ->
          service.currentUser = response.data.user
          if service.isAuthenticated()
            $rootScope.$broadcast "event:authorized", service.currentUser
            $state.go('data-sets')

      logout: () ->
        $http.delete('/api/v1/sessions').then (response) ->
          $http.defaults.headers.common['X-CSRF-Token'] = response.data.csrfToken
          service.currentUser = null
          $state.go('login')

      register: (email, password, confirm_password) ->
        $http.post("/api/v1/users",
          user:
            email: email
            password: password
            password_confirmation: confirm_password
        ).then (response) ->
          service.currentUser = response.data
          if service.isAuthenticated()
            $rootScope.$broadcast "event:authorized", service.currentUser
            $state.go('data-sets')

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