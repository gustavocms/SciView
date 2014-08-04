(function() {
    var module = angular.module('sv.charts.metadata.controllers', []);

    module.controller('MetadataController', ['$scope', '$log', 'MetadataService', 'ModalService', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $log, MetadataService, ModalService, SeriesTagsService, SeriesAttributesService) {

            $scope.parameters = JSON.parse($('#chartSeries').text());

            $scope.seriesList = MetadataService.query($scope.parameters);

            $scope.addMetadata = function(series) {
                var result = ModalService.showModal({
                    controller: 'NewMetadataController',
                    templateUrl: '/assets/charts/metadata/add_metadata_form.html',
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
                    bodyText: 'Are you sure you want to delete this attribute?<br><br><strong>' + key + '</strong>'
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
                    bodyText: 'Are you sure you want to delete this tag?<br><br><strong>' + tag + '</strong>'
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

    module.controller('NewMetadataController', ['$scope', '$modalInstance', '$log', '$q', 'series', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $modalInstance, $log, $q, series, SeriesTagsService, SeriesAttributesService) {
            $scope.newMetadata = {
                series: series,
                tag: "",
                attribute: "",
                value: ""
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };

            $scope.ok = function (metadataForm) {
                if (metadataForm.$valid) {

                    var promises = [];

                    if ($scope.newMetadata.tag.length > 0) {
                        //asynchronous saving
                        var promise = saveNewTag();

                        //add the promise to the array to wait for all to complete
                        promises.push(promise);
                    };

                    if ($scope.newMetadata.attribute.length > 0) {
                        //asynchronous saving
                        var promise = saveNewAttribute();

                        //add the promise to the array to wait for all to complete
                        promises.push(promise);
                    };

                    //wait for all saving to be completed and then closes.
                    //defining finally as a string for IE compatibility (https://docs.angularjs.org/api/ng/service/$q)
                    $q.all(promises)['finally'](function() {
                        $modalInstance.close($scope.newMetadata);
                    });
                }
            };

            function saveNewTag() {
                var tagData = {tag: $scope.newMetadata.tag};

                //ajax call
                var promise = SeriesTagsService.save(
                    {seriesId: $scope.newMetadata.series.key}, tagData,
                    //onSuccess promise function
                    function () {
                        //update scope with new object
                        $scope.newMetadata.series.tags.push(tagData.tag);
                    }).$promise;

                //return promise of the saving call
                return promise;
            }

            function saveNewAttribute() {
                var attrData = {
                    attribute: $scope.newMetadata.attribute,
                    value: $scope.newMetadata.value
                };

                //ajax call
                var promise = SeriesAttributesService.save(
                    {seriesId: $scope.newMetadata.series.key}, attrData,
                    //onSuccess promise function
                    function () {
                        //update scope with new object
                        $scope.newMetadata.series.attributes[attrData.attribute] = attrData.value;
                    }).$promise;

                //return promise of the saving call
                return promise;
            };

        }
    ]);
})();