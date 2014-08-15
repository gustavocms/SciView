(function() {
    var module = angular.module('sv.ui.controllers.metadata', []);

    module.controller('MetadataController', ['$scope', '$log', '$q', 'ModalService', 'MetadataService', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $log, $q, ModalService, MetadataService, SeriesTagsService, SeriesAttributesService) {

            $scope.metaState = {
                //$scope.channel.title from parent controller
                parameters: {series_1: $scope.series.title},
                showForm: false
            };

            //wait for the promise to succesfully finish
            MetadataService.query($scope.metaState.parameters, function(seriesList) {
                $scope.seriesData = seriesList[0];
            });

            //form model
            $scope.newMetadata = {
                tag: "",
                attribute: "",
                value: ""
            };

            $scope.saveMetaChannel = function () {
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

                //wait for all saving to be completed and then closes the form and cleanup the model.
                //defining finally as a string for IE compatibility (https://docs.angularjs.org/api/ng/service/$q)
                $q.all(promises)['finally'](function() {
                    $scope.metaState.showForm = false;
                    $scope.newMetadata.tag = "";
                    $scope.newMetadata.attribute = "";
                    $scope.newMetadata.value = "";
                });
            };

            function saveNewTag() {
                var tagData = {tag: $scope.newMetadata.tag};

                //ajax call
                var promise = SeriesTagsService.save(
                    {seriesId: $scope.seriesData.key}, tagData,
                    //onSuccess promise function
                    function () {
                        if ($scope.seriesData.tags.indexOf(tagData.tag) == -1) {
                            //update scope with new object
                            $scope.seriesData.tags.push(tagData.tag);
                        }
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
                    {seriesId: $scope.seriesData.key}, attrData,
                    //onSuccess promise function
                    function () {
                        //update scope with new object
                        $scope.seriesData.attributes[attrData.attribute] = attrData.value;
                    }).$promise;

                //return promise of the saving call
                return promise;
            };


            $scope.removeAttribute = function(key) {
                var result = ModalService.showModal({}, {
                    actionButtonText: 'Delete',
                    headerText: 'Remove attribute?',
                    bodyText: 'Are you sure you want to delete this attribute?<br><br><strong>' + key + ':' + $scope.seriesData.attributes[key] + '</strong>'
                });

                result.then(function () {
                    //ajax call
                    SeriesAttributesService.delete({
                            seriesId: $scope.seriesData.key,
                            attributeId: key
                        }, {},
                        //onSuccess promise function
                        function () {
                            //update scope removing object
                            delete $scope.seriesData.attributes[key];
                        });
                });
            };

            $scope.removeTag = function(tag) {
                var result = ModalService.showModal({}, {
                    actionButtonText: 'Delete',
                    headerText: 'Remove tag?',
                    bodyText: 'Are you sure you want to delete this tag?<br><br><strong>' + tag + '</strong>'
                });

                result.then(function () {
                    //ajax call
                    SeriesTagsService.delete({
                            seriesId: $scope.seriesData.key,
                            tagId: tag
                        }, {},
                        //onSuccess promise function
                        function () {
                            //update scope removing object
                            $scope.seriesData.tags.splice($scope.seriesData.tags.indexOf(tag), 1);
                        });
                });
            };
        }
    ]);
})();