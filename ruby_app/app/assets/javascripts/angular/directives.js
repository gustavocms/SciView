var metadataDirectives = angular.module('metadataDirectives', []);

metadataDirectives.directive('addMetadataForm', function(){
    return {
        restrict: 'E',
        templateUrl: '/assets/add_metadata_form.html'
    };
});