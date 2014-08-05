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

        // Function to change state of expanded or retracted object
        var toggleExpandRetract = function(obj) {
            if(obj.state === "retracted") 
                obj.state = "expanded";
            else 
                obj.state = "retracted";
        };


        // TEMPORARY
        $http.get('datasets/multiple.json?series_1=sample_0a3803_1405960534&series_2=sample_640636_1404681975')
          .success(function(data) { 
            console.log(data.data);
            $scope.data_sets.push(
              {
                id: '3',
                title: 'TEMP TITLE',
                batch: [
                  { title: 'Pressure', chart: 'assets/graph_1.svg', channel: [
                    { title: 'Pressure Sensors', group: [{ title: 'fuel_pressure-d', category: 'pressure', key: { color: '#FF00D8', style: "dashed" } }]}
                  ]}
                ]
              }          
            );
          });
    }

]);
