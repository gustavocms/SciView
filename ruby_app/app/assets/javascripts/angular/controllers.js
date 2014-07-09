(function() {
    var module = angular.module('metadataControllers', ['ngRoute']);

    module.controller('LoadDataController', ['$scope', '$log', 'MetadataService', 'ModalService',
        function ($scope, $log, MetadataService, ModalService) {

            $scope.seriesList = MetadataService.query();

            this.addMetadata = function(series) {
                var result = ModalService.showModal({
                    controller: 'NewMetadataController',
                    templateUrl: '/assets/add_metadata_form.html',
                    resolve: {
                        series: function () {
                            return series;
                        }
                    }
                }, {});

                result.then(function (newMetadata) {
                    $log.info(newMetadata);
                });
            };

            this.removeAttribute = function(series, key) {
                var result = ModalService.showModal({}, {
                    actionButtonText: 'Delete',
                    headerText: 'Remove attribute?',
                    bodyText: 'Are you sure you want to delete this attribute?'
                });

                result.then(function () {
                    delete series.attributes[key];
                    $log.info('attribute deleted');
                });
            };

            this.removeTag = function(series, tag) {
                var result = ModalService.showModal({}, {
                    actionButtonText: 'Delete',
                    headerText: 'Remove tag?',
                    bodyText: 'Are you sure you want to delete this tag?'
                });

                result.then(function () {
                    series.tags.splice(series.tags.indexOf(tag), 1);
                    $log.info('tag deleted');
                });
            };

        }
    ]);

    module.controller('NewMetadataController', ['$scope', '$modalInstance', '$log', 'series',
        function ($scope, $modalInstance, $log, series) {
            $scope.newMetadata = {
                series: series,
                tag: "",
                attribute: "",
                value: ""
            };

            $scope.ok = function (metadataForm) {
                if (metadataForm.$valid) {
                    $modalInstance.close($scope.newMetadata);
                }
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        }
    ]);
})();