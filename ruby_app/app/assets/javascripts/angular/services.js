(function() {
    var module = angular.module('metadataServices', ['ngResource']);

    module.factory('MetadataService', ['$resource',
        function ($resource) {
            return $resource('/datasets/metadata');
        }]);

    //TODO: test with $http
    module.factory('SeriesTagsService', ['$resource',
        function ($resource) {
            return $resource('/datasets/:seriesId/tags', {}, {
                save: {
                    method: 'POST',
                    xsrfHeaderName: 'X-CSRF-Token',
                    xsrfCookieName: 'csrf_token'
                }
            });
        }]);

    //TODO: test with $http
    module.factory('SeriesAttributesService', ['$resource',
        function ($resource) {
            return $resource('/datasets/:seriesId/attributes', {}, {
                save: {
                    method: 'POST',
                    xsrfHeaderName: 'X-CSRF-Token',
                    xsrfCookieName: 'csrf_token'
                }
            });
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