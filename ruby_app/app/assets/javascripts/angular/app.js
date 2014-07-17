(function() {
    var app = angular.module('sciViewApp', [
        'ui.router',
        'ui.bootstrap',
        'ui.utils',
        'metadataServices',
        'metadataControllers'
    ]);

    app.config(['$stateProvider', '$urlRouterProvider', '$locationProvider',
        function ($stateProvider, $urlRouterProvider, $locationProvider) {

            $stateProvider
                .state('multiChart', {
                    url: "/charts/multiple",
                    views: {
                        "saveChart": {
                            templateUrl: "/assets/save_chart.html",
                            controller: 'SaveChartController',
                            resolve: {
                                // looking for the parameters on the hidden field to inject on the controller
                                seriesParams: function () {
                                    var seriesParams = JSON.parse($('#chartSeries').text());
                                    return seriesParams;
                                }
                            }
                        },
                        "metadata": {
                            templateUrl: "/assets/metadata.html",
                            controller: 'MetadataController',
                            resolve: {
                                // looking for the parameters on the hidden field to inject on the controller
                                seriesParams: function () {
                                    var seriesParams = JSON.parse($('#chartSeries').text());
                                    return seriesParams;
                                }
                            }
                        }
                    }

                })
                .state('singleChart', {
                    url: "/charts/:chartId",
                    templateUrl: "/assets/metadata.html",
                    controller: 'MetadataController',
                    resolve: {
                        // looking for the parameters on the hidden field to inject on the controller
                        seriesParams: function () {
                            var seriesParams = JSON.parse($('#chartSeries').text());
                            return seriesParams;
                        }
                    }
                });

            // configure html5 to get links working on jsfiddle
            $locationProvider.html5Mode(true);
        }]);

})();
