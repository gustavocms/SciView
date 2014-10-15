module = angular.module('sv.ui.services')

module.factory "Session", [
  "$location", "$http", "$q",
  ($location, $http, $q) ->

    # Redirect to the given url (defaults to '/')
    redirect = (url) ->
      url = url or "/"
      $location.path url
    service =
      login: (email, password) ->
        $http.post("/api/v1/sessions",
          user:
            email: email
            password: password
        ).then (response) ->
          service.currentUser = response.data.user

          #$location.path(response.data.redirect);
          $location.path "/record"  if service.isAuthenticated()


      logout: (redirectTo) ->
        $http.delete('/api/v1/sessions').then (response) ->
          $http.defaults.headers.common['X-CSRF-Token'] = response.data.csrfToken
          service.currentUser = null
          redirect(redirectTo)

      register: (email, password, confirm_password) ->
        $http.post("/api/v1/users",
          user:
            email: email
            password: password
            password_confirmation: confirm_password
        ).then (response) ->
          service.currentUser = response.data
          $location.path "/record"  if service.isAuthenticated()


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