(function() {
    var module = angular.module('metadataControllers', ['ngRoute']);

    module.controller('LoadDataController', ['$scope', '$location', 'Datasets',
        function ($scope, $location, Datasets) {
            this.params = $location.search();
            $scope.series = Datasets.query();

            this.removeTag = function(serie, tag) {
                $('<div></div>').appendTo('body')
                    .html('<div><h6>Are you sure?</h6></div>')
                    .dialog({
                        modal: true,
                        resizable: false,
                        title: 'Remove Tag',
                        width: 'auto',
                        buttons: {
                            "Delete": function () {
//                                $.ajax({
//                                    url: "/datasets/" + series_key + "/tags/" + tag,
//                                    type: "DELETE",
//                                    async: false,
//                                    success: function(data) {
                                var index = serie.tags.indexOf(tag);
                                serie.tags.splice(index, 1);
                                $scope.$apply();
//                                    }
//                                });

                                $(this).dialog("close");
                            },
                            Cancel: function () {
                                $(this).dialog("close");
                            }
                        },
                        close: function (event, ui) {
                            $(this).remove();
                        }
                    });
            };

        }
    ]);

    module.controller('NewMetadataController', ['$scope',
        function ($scope) {
            this.metadata = {};

            this.addMetadata = function (serie) {
                serie.tags.push(this.metadata.tag);
                this.metadata = {};
            };
        }
    ]);
})();