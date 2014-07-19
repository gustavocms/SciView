(function() {
    var module = angular.module('metadataServices', ['ngResource']);

    module.factory('ChartsService', ['$resource',
        function ($resource) {
            return $resource('/charts');
        }]);

    module.factory('MetadataService', ['$resource',
        function ($resource) {
            return $resource('/datasets/metadata');
        }]);

    module.factory('SeriesTagsService', ['$resource',
        function ($resource) {
            return $resource('/datasets/:seriesId/tags/:tagId');
        }]);

    module.factory('SeriesAttributesService', ['$resource',
        function ($resource) {
            return $resource('/datasets/:seriesId/attributes/:attributeId');
        }]);

    module.service('ModalService', ['$modal',
        function ($modal) {

            var modalDefaults = {
                backdrop: true,
                keyboard: true,
                modalFade: true,
                templateUrl: '/assets/confirmation.html'
            };

            var modalOptions = {
                closeButtonText: 'Cancel',
                actionButtonText: 'OK',
                headerText: 'Proceed?',
                bodyText: 'Perform this action?'
            };

            this.showModal = function (customModalDefaults, customModalOptions) {
                if (!customModalDefaults) customModalDefaults = {};
                customModalDefaults.backdrop = 'static';
                return this.show(customModalDefaults, customModalOptions);
            };

            this.show = function (customModalDefaults, customModalOptions) {
                //Create temp objects to work with since we're in a singleton service
                var tempModalDefaults = {};
                var tempModalOptions = {};

                //Map angular-ui modal custom defaults to modal defaults defined in service
                angular.extend(tempModalDefaults, modalDefaults, customModalDefaults);

                //Map modal.html $scope custom properties to defaults defined in service
                angular.extend(tempModalOptions, modalOptions, customModalOptions);

                if (!tempModalDefaults.controller) {
                    tempModalDefaults.controller = function ($scope, $modalInstance) {
                        $scope.modalOptions = tempModalOptions;
                        $scope.modalOptions.ok = function (result) {
                            $modalInstance.close(result);
                        };
                        $scope.modalOptions.close = function (result) {
                            $modalInstance.dismiss('cancel');
                        };
                    }
                }

                return $modal.open(tempModalDefaults).result;
            };

        }]);
})();