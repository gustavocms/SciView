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
                //nested state. More on this:
                //https://github.com/angular-ui/ui-router/wiki/Nested-States-%26-Nested-Views
                .state('multiChart.edit', {
                    parent: 'multiChart',
                    views: {
                        //relative views naming. More on this:
                        //https://github.com/angular-ui/ui-router/wiki/Multiple-Named-Views#view-names---relative-vs-absolute-names
                        'saveChart@': {
                            templateUrl: "/assets/save_chart.edit.html",
                            controller: 'SaveChartController'
                        }
                    }
                })
                .state('multiChart.saved', {
                    parent: 'multiChart',
                    views: {
                        'saveChart@': {
                            template:  '<h4>Saved</h4>'
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
