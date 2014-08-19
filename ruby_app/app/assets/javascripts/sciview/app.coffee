app = angular.module('sciview', [
  'ngAnimate'
  'ngCookies'
  'ngRoute'
  'ui.router'
  'ui.bootstrap'
  'ui.utils'
  'sv.common.services'
  'sv.charts.metadata.services'
  'sv.ui.controllers.metadata'
  'sv.ui.services'
])

# first thing to run after loading
app.run(['$rootScope', '$state', '$stateParams',
  ($rootScope, $state, $stateParams) ->
#     It's very handy to add references to $state and $stateParams to the $rootScope
#     so that you can access them from any scope within your applications.For example,
#     <li ui-sref-active="active }"> will set the <li> # to active whenever
#     'contacts.list' or one of its decendents is active.
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
])

#routing configuration
app.config(['$urlRouterProvider', '$stateProvider',
  ($urlRouterProvider, $stateProvider) ->

    $urlRouterProvider.otherwise('/data-sets')

    $stateProvider
      .state('data-sets', {
          url: '/data-sets',
          templateUrl: '/assets/sciview/data_sets.html',
          controller: 'DataSetListController'
      })
      .state('data-sets.single', {
          url: '/:dataSetId',
          templateUrl: '/assets/sciview/data_set.html',
          controller: 'DataSetController'
      })
      .state('data-sets.single.discuss', {
          url: '/discuss',
          templateUrl: '/assets/sciview/discuss.html',
          controller: 'DiscussController'
      })
      .state('navigator', {
          url: '/navigator',
          templateUrl: '/assets/sciview/navigator.html',
          controller: 'NavigatorController'
      })
      .state('navigator.upload', {
          url: '/upload',
          templateUrl: '/assets/sciview/partials/upload.html',
          controller: 'UploadController'
      })
])
