(function() {
    var app = angular.module('sciview')

    app.controller('NavigatorController', [
        '$scope',
        'Sources',
        function($scope, Sources) {

            $scope.sources = Sources.getDataSources();

            $scope.navigator = {
              search_query: ""
            };

        }
    ]);

})();