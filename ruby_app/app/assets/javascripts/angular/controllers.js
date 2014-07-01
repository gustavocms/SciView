var metadataControllers = angular.module('metadataControllers', []);

//avoid minification problems by manually injecting dependencies
metadataControllers.controller('MetadataCtrl', ['$scope', 'Datasets',
    function($scope, Datasets) {

        $scope.series = Datasets.query();

    }
]);
