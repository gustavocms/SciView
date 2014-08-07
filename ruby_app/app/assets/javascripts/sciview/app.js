var app = angular.module('sciview', [
    'ngAnimate',
    'ngCookies',
    'ngRoute',
    'ui.router',
    'ui.bootstrap',
    'ui.utils',
    'sv.common.services',
    'sv.charts.metadata.services',
    'sv.ui.controllers.metadata',
    'sv.ui.services'
]).config(function($routeProvider, $locationProvider, $httpProvider, $stateProvider, $urlRouterProvider) {

    $urlRouterProvider.otherwise('/data-sets/0');
    $urlRouterProvider.when('/data-sets', '/data-sets/0');
    
    $stateProvider      
        .state('data-sets', {
            url: '/data-sets',
            templateUrl: '/assets/sciview/data_sets.html',
            controller: 'DataSetController'
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
        ;

});
