var metadataServices = angular.module('metadataServices', ['ngResource']);

metadataServices.factory('Datasets', ['$resource',
    function($resource){
        return $resource('/datasets/metadata', {}, {
            query: {method:'GET', params:{series_1:'paul-sin-1',series_2:'paul-sin-2'}, isArray:true}
        });
    }]);