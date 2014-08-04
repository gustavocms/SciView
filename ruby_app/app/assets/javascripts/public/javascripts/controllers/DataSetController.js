app.controller('DataSetController', [
    '$scope',
    '$rootScope',
    '$location',
    '$stateParams',
    '$state',
    'DataSets',
    function($scope, $rootScope, $location, $stateParams, $state, DataSets) {

        // Get all Data Sets        
        $scope.data_sets = DataSets.getDataSets();
        // Set current Data Set
        $scope.current_data_set = $scope.data_sets[$stateParams.dataSetId];
        
        // Make $state available in $scope
        $scope.$state = $state;        

        // Expand and retract group channels
        $scope.toggleGroup = function(channel) {
            toggleExpandRetract(channel);
        };

        // Function to change state of expanded or retracted object
        var toggleExpandRetract = function(obj) {
            if(obj.state === "retracted") 
                obj.state = "expanded";
            else 
                obj.state = "retracted";
        };
    }

]);