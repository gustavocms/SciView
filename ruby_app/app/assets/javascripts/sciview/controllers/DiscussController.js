(function() {
    var app = angular.module('sciview')

    app.controller('DiscussController', [
        '$scope',
        'Observations',
        function($scope, Observations) {
            $scope.observations = Observations.getObservations();
        }
    ]);

})();
