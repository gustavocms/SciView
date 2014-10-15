module = angular.module('sciview')

module.factory "DeviseInterceptor", [
   "$rootScope", "$q"
  ( $rootScope, $q) ->

    responseError: (rejection) ->
      if rejection.status is 401
        $rootScope.$broadcast "event:unauthorized"
        console.log rejection

      return $q.reject rejection
]

