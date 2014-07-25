(function() {
    var module = angular.module('sv.charts.save.services', ['ngResource']);

    module.factory('ChartsService', ['$resource',
        function ($resource) {
            return $resource('/charts');
        }]);
})();