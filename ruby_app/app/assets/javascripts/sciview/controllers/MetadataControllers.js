(function() {
    var module = angular.module('sv.ui.controllers.metadata', []);

    module.controller('MetadataController', ['$scope','$q', '$timeout', 'MetadataService', 'SeriesTagsService', 'SeriesAttributesService',
        function ($scope, $q, $timeout, MetadataService, SeriesTagsService, SeriesAttributesService) {

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

            $scope.deleteMeta = {
                selected_tag: {},
                selected_attr: {},
                selected_key: {},
                is_attr: false,
                remove_screen: false,
                remove_flash: false
            };

            $scope.removeTagView = function(tag) {
                // Clear selected tag
                $scope.deleteMeta.selected_tag = {};
                // Remove attr setting (for delete function)
                $scope.deleteMeta.is_attr = false;
                // Show the remove screen
                $scope.deleteMeta.remove_screen = true;
                // Set selected tag
                $scope.deleteMeta.selected_tag = tag;
            };

            $scope.removeAttrView = function(key, value) {
                // Clear selected attr
                $scope.deleteMeta.selected_attr = {};
                // Set selected key
                $scope.deleteMeta.selected_key = key;
                // Set attr setting to true (for delete selection)
                $scope.deleteMeta.is_attr = true;
                // Show remove screen
                $scope.deleteMeta.remove_screen = true;
                // Build attribute string 
                $scope.deleteMeta.selected_attr = key + ": " + value;
            };  

            $scope.hideRemoveView = function() {
                // Hide remove screen 
                $scope.deleteMeta.remove_screen = false;
            };

            $scope.removeFlash = function() {
                // Show alert
                $scope.deleteMeta.remove_flash = true;
                // Remove alert
                $timeout(function() {
                    $scope.deleteMeta.remove_flash = false;
                }, 1500);
            };

            $scope.removeTag = function(tag) {
                //ajax call
                SeriesTagsService.delete({
                        seriesId: $scope.seriesData.key,
                        tagId: tag
                    }, {},
                    //onSuccess promise function
                    function () {
                        //update scope removing object
                        $scope.seriesData.tags.splice($scope.seriesData.tags.indexOf(tag), 1);
                        $scope.deleteMeta.remove_screen = false;
                        $scope.removeFlash();
                    });
            };

            $scope.removeAttribute = function(key) {
                //ajax call
                SeriesAttributesService.delete({
                        seriesId: $scope.seriesData.key,
                        attributeId: key
                    }, {},
                    //onSuccess promise function
                    function () {
                        //update scope removing object
                        delete $scope.seriesData.attributes[key];
                        $scope.deleteMeta.remove_screen = false;
                        $scope.removeFlash();
                    });
            };
        }
    ]);
})();