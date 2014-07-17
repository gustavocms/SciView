(function() {
    var module = angular.module('metadataControllers', ['ngRoute']);

    module.controller('SaveChartController', ['$scope', '$log', 'seriesParams',
        function ($scope, $log, seriesParams) {

            var chartName = "Chart for ";
            angular.forEach(seriesParams,
                function(value, key) {
                    chartName += value + ",";
                });

            $scope.chart = {
                name: chartName.slice(0,-1),
                series: seriesParams
            };
        }
    ]);

    module.controller('MetadataController', ['$scope', '$log', 'MetadataService', 'ModalService', 'seriesParams', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $log, MetadataService, ModalService, seriesParams, SeriesTagsService, SeriesAttributesService) {

            $scope.parameters = seriesParams;

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
                    //ajax call
                    SeriesAttributesService.delete({
                            seriesId: series.key,
                            attributeId: key
                        }, {},
                        //onSuccess promise function
                        function () {
                            //update scope removing object
                            delete series.attributes[key];
                        });
                });
            };

            $scope.removeTag = function(series, tag) {
                var result = ModalService.showModal({}, {
                    actionButtonText: 'Delete',
                    headerText: 'Remove tag?',
                    bodyText: 'Are you sure you want to delete this tag?'
                });

                result.then(function () {
                    //ajax call
                    SeriesTagsService.delete({
                            seriesId: series.key,
                            tagId: tag
                        }, {},
                        //onSuccess promise function
                        function () {
                            //update scope removing object
                            series.tags.splice(series.tags.indexOf(tag), 1);
                        });
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

            //TODO: duplicate calling $modalInstance.close
            $scope.ok = function (metadataForm) {
                if (metadataForm.$valid) {

                    if ($scope.newMetadata.tag.length > 0) {

                        var tagData = {tag: $scope.newMetadata.tag};

                        //ajax call
                        SeriesTagsService.save(
                            {seriesId: $scope.newMetadata.series.key}, tagData,
                            //onSuccess promise function
                            function() {
                                //update scope with new object
                                $scope.newMetadata.series.tags.push(tagData.tag);

                                $modalInstance.close($scope.newMetadata);
                            });
                    };

                    if ($scope.newMetadata.attribute.length > 0) {

                        var attrData = {
                            attribute: $scope.newMetadata.attribute,
                            value: $scope.newMetadata.value
                        };

                        //ajax call
                        SeriesAttributesService.save(
                            {seriesId: $scope.newMetadata.series.key}, attrData,
                            //onSuccess promise function
                            function() {
                                //update scope with new object
                                $scope.newMetadata.series.attributes[attrData.attribute] = attrData.value;

                                $modalInstance.close($scope.newMetadata);
                            });
                    };
                }
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };
        }
    ]);
})();