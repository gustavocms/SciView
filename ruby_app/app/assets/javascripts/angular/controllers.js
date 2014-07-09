(function() {
    var module = angular.module('metadataControllers', ['ngRoute']);

    module.controller('LoadDataController', ['$scope', '$log', 'MetadataService', 'ConfirmationService',
        function ($scope, $log, MetadataService, ConfirmationService) {

            $scope.seriesList = MetadataService.query();

            this.addMetadata = function(series, tag) {
                var result = ConfirmationService.showModal({
                    controller: 'NewMetadataController',
                    templateUrl: '/assets/add_metadata_form.html'
                }, {});

                result.then(function (newMetadata) {
                    $log.info(newMetadata);
                });
            };

            this.removeAttribute = function(series, key) {
                var result = ConfirmationService.showModal({}, {
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
                var result = ConfirmationService.showModal({}, {
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

    module.controller('NewMetadataController', ['$scope', '$modalInstance',
        function ($scope, $modalInstance) {
            $scope.tag = "";
            $scope.attribute = "";
            $scope.value = "";

            $scope.ok = function () {
                $modalInstance.close({tag: $scope.tag, attribute: $scope.attribute, value: $scope.value});
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        }
    ]);
})();