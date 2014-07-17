(function() {
    var module = angular.module('metadataRoutes', ['ngRoute']);

//    module.config(['$routeProvider', '$locationProvider',
//        function ($routeProvider, $locationProvider) {
//            $routeProvider.
//                when('/charts/multiple', {
//                    templateUrl: '/assets/metadata.html',
//                    controller: 'MetadataController',
//                    resolve: {
//                        // looking for the parameters on the hidden field to inject on the controller
//                        seriesParams: function () {
//                            var seriesParams = JSON.parse($('#chartSeries').text());
//                            return seriesParams;
//                        }
//                    }
//                }).
//                when('/charts/:chartId', {
//                    templateUrl: '/assets/metadata.html',
//                    controller: 'MetadataController',
//                    resolve: {
//                        // looking for the parameters on the hidden field to inject on the controller
//                        seriesParams: function () {
//                            var seriesParams = JSON.parse($('#chartSeries').text());
//                            return seriesParams;
//                        }
//                    }
//                });
//
//            // configure html5 to get links working on jsfiddle
//            $locationProvider.html5Mode(true);
//        }]);
})();