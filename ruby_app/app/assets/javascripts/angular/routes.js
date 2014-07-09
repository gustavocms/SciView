(function() {
    var module = angular.module('metadataRoutes', ['ngRoute']);

    module.config(['$routeProvider', '$locationProvider',
        function ($routeProvider, $locationProvider) {
            $routeProvider.
                when('/charts/multiple', {
                    templateUrl: '/assets/metadata.html',
                    controller: 'MetadataController'
                }).
                when('/charts/:chartId', {
                    templateUrl: '/assets/metadata.html',
                    controller: 'MetadataController'
                });

            // configure html5 to get links working on jsfiddle
            $locationProvider.html5Mode(true);
        }]);
})();