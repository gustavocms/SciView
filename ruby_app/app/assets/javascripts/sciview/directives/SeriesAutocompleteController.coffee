module = angular.module("sv.ui.controllers")

module.controller "SeriesAutocompleteController", [
  "$scope"
  "SeriesService"
  ($scope, SeriesService) ->

    joinAttributes = (attributes) ->
      attributesList = ''
      angular.forEach(attributes, (value, key) ->
        attributesList += key + ':' + value + ', '
      )
      return attributesList

    #    TODO: implement filtering on the serverside
    $scope.querySeriesList = (typed) ->

      matcher = RegExp(typed, 'i')
      filteredSeries = []

      # full list of series
      SeriesService.findAll().then (data) ->
        $scope.seriesList = data

        # search seriesList for matching items
        angular.forEach($scope.seriesList, (item, i) ->
          seriesTerms = item.key + '|' + item.tags.join('|') + joinAttributes(item.attributes)

          if matcher.test(seriesTerms)
            # used to control exhibition at autocomplete
            item.hasTags = item.tags.length > 0
            item.hasAttributes = joinAttributes(item.attributes).length > 0

            # add item to autocomplete list
            filteredSeries.push(item)
        )

        return filteredSeries
]