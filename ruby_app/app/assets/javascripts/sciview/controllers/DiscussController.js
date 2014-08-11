app.controller('DiscussController', [
    '$scope',
    '$rootScope',
    '$location',
    '$state',
    'Observations',
    function($scope, $rootScope, $location, $state, Observations) {
        $scope.$state = $state;        

        $scope.observations = Observations.getObservations();

    }
]);
