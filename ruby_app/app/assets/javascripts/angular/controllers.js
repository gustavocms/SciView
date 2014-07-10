(function() {
    var module = angular.module('metadataControllers', ['ngRoute']);

    module.controller('MetadataController', ['$scope', '$log', 'MetadataService', 'ModalService', '$routeParams',
        function ($scope, $log, MetadataService, ModalService, $routeParams) {

            $scope.parameters = $routeParams;

            $scope.seriesList = MetadataService.query($scope.parameters);

            $scope.addMetadata = function(series) {
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

            $scope.removeAttribute = function(series, key) {
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

            $scope.removeTag = function(series, tag) {
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

    module.controller('NewMetadataController', ['$scope', '$modalInstance', '$log', 'series', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $modalInstance, $log, series, SeriesTagsService, SeriesAttributesService) {
            $scope.newMetadata = {
                series: series,
                tag: "",
                attribute: "",
                value: ""
            };

            $scope.ok = function (metadataForm) {
                if (metadataForm.$valid) {

                    var closeDialog = false;

                    if ($scope.newMetadata.tag.length > 0) {

                        var postData = {tag: $scope.newMetadata.tag};

                        //ajax call
                        SeriesTagsService.save(
                            {seriesId: $scope.newMetadata.series.key}, postData,
                            //onSuccess promise function
                            function() {
                                //update scope with new object
                                $scope.newMetadata.series.tags.push(postData.tag);

                                closeDialog = true;
                            });
                    };

                    if ($scope.newMetadata.attribute.length > 0) {

                        var postData = {
                            attribute: $scope.newMetadata.attribute,
                            value: $scope.newMetadata.value
                        };

                        //ajax call
                        SeriesAttributesService.save(
                            {seriesId: $scope.newMetadata.series.key}, postData,
                            //onSuccess promise function
                            function() {
                                //update scope with new object
                                $scope.newMetadata.series.attributes[postData.attribute] = postData.value;
                                closeDialog = true;
                            });
                    };

                    if (closeDialog) {
                        $modalInstance.close($scope.newMetadata);
                    }
                }
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        }
    ]);
})();