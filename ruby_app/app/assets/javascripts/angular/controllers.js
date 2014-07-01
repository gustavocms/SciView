var metadataControllers = angular.module('metadataControllers', []);

//avoid minification problems by manually injecting dependencies
metadataControllers.controller('LoadDataController', ['$scope', 'Datasets',
    function($scope, Datasets) {
        $scope.series = Datasets.query();
    }
]);

//avoid minification problems by manually injecting dependencies
metadataControllers.controller('NewMetadataController', ['$scope',
    function($scope) {
        this.metadata={};

        this.addMetadata = function(serie){
            serie.tags.push(this.metadata.tag);
            this.metadata={};
        };
    }
]);
