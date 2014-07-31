(function() {
    var module = angular.module('sv.charts.metadata.services', ['ngResource']);

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
})();