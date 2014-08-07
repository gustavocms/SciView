(function () {
    var module = angular.module('sv.charts.save.controllers', []);

    module.controller('SaveChartController', ['$scope', '$log', '$state', 'ChartsService',
        function ($scope, $log, $state, ChartsService) {

            var seriesList = JSON.parse($('#chartSeries').text());

            var chartName = "Chart for ";
            angular.forEach(seriesList,
                function (value, key) {
                    chartName += value + ",";
                });

            $scope.chart = {
                name: chartName.slice(0, -1),
                series: seriesList
            };

            $scope.confirm = function () {

                //ajax call
                ChartsService.save({}, $scope.chart,
                    //onSuccess promise function
                    function () {
                        $state.go('multiChart.saved');
                    },
                    //onError promise function
                    function (error) {
                        angular.forEach(error.data, function (value, key) {
                            value.map(function (msg) {
                                $scope.addAlert('danger', key + ' ' + msg);
                            });
                        });
                    });
            };


            $scope.alerts = [];

            $scope.addAlert = function (type, msg) {
                $scope.alerts.push({type: type, msg: msg});
            };

            $scope.closeAlert = function (index) {
                $scope.alerts.splice(index, 1);
            };
        }
    ]);
})();