(function() {
    var app = angular.module('sciViewApp', [
        'ui.router',
        'ui.bootstrap',
        'ui.utils',
        'metadataServices',
        'metadataControllers'
    ]);

    app.run(['$rootScope', '$state', '$stateParams',
        function ($rootScope, $state, $stateParams) {
            // It's very handy to add references to $state and $stateParams to the $rootScope
            // so that you can access them from any scope within your applications.For example,
            // <li ui-sref-active="active }"> will set the <li> // to active whenever
            // 'contacts.list' or one of its decendents is active.
            $rootScope.$state = $state;
            $rootScope.$stateParams = $stateParams;
        }]);


    app.config(['$stateProvider', '$urlRouterProvider', '$locationProvider',
        function ($stateProvider, $urlRouterProvider, $locationProvider) {

            $stateProvider
                .state('multiChart', {
                    url: "/charts/multiple",
                    views: {
                        'saveChart@': {
                            templateUrl: "/assets/save_chart.html"
                        },
                        'metadata@': {
                            templateUrl: "/assets/metadata.html",
                            controller: 'MetadataController'
                        }
                    }

                })

                // Notice that this state has no 'url'. States do not require a url. You can use them
                // simply to organize your application into "places" where each "place" can configure
                // only what it needs. The only way to get to this state is via $state.go (or transitionTo)
                .state('multiChart.edit', {
                    parent: 'multiChart',
                    views: {
                        'saveChart@': {
                            templateUrl: "/assets/save_chart.edit.html",
                            controller: 'SaveChartController'
                        }
                    }

                })
                .state('singleChart', {
                    url: "/charts/:chartId",
                    templateUrl: "/assets/metadata.html",
                    controller: 'MetadataController'
                });

            // configure html5 to get links working on jsfiddle
            $locationProvider.html5Mode(true);
        }]);

})();
