app.controller('DataSetController', [
    '$scope',
    '$rootScope',
    '$location',
    '$stateParams',
    '$state',
    'DataSets',
    '$http',
    function($scope, $rootScope, $location, $stateParams, $state, DataSets, $http) {

        // Get all Data Sets        
        $scope.data_sets = DataSets.getDataSets();


        // Set current Data Set
        setCurrentDataSet = function() {
          $scope.current_data_set = $scope.data_sets[$stateParams.dataSetId];
        };

        setCurrentDataSet();
        
        // Make $state available in $scope
        $scope.$state = $state;        

        // Expand and retract group channels
        $scope.toggleGroup = function(channel) {
            toggleExpandRetract(channel);
        };

        $scope.addChart = function() {
          this.current_data_set.addChart();
        }

        $scope.addSeries = function(name) { console.log('addSeries', name); };

        // Function to change state of expanded or retracted object
        var toggleExpandRetract = function(obj) {
            if(obj.state === "retracted") 
                obj.state = "expanded";
            else 
                obj.state = "retracted";
        };
    }

]);
