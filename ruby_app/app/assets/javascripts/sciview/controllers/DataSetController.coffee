module = angular.module("sv.ui.controllers")

module.controller('DataSetController', [
  '$scope'
  '$stateParams'
  '$timeout'
  '$q'
  'ViewState'
  'SeriesService'
  'Observation'
  'DS'
  ($scope, $stateParams, $timeout, $q, ViewState, SeriesService, Observation, DS) ->

    # waits for the parent loading to finish
    $scope.deferredDatasetsLoading.promise.then ->

      # find the correct dataset in parent's scope
      filteredDS = $scope.$parent.data_sets.filter (ds) ->
        ds.id.toString() == $stateParams.dataSetId

      $scope.current_data_set = filteredDS[0]

      observationFunction = (uuid) ->
        -> console.log("observation function for uuid #{uuid} and $scope #{$scope}")

      chart.setObservationFunction(observationFunction) for chart in $scope.current_data_set.charts
      
      # used to manage changes that may be reverted
      $scope.temporary_data_set =
        title: $scope.current_data_set.title


    # TODO: is this necessary to keep in this controller? Can it all be moved into DiscussController?
    # There will need to be a callback function generated somewhere along the line to allow
    # interaction on the D3 chart to trigger a newObservation call. Can this just be threaded through
    # $parent from the other controller?
    $scope.observationsLoading = $q.defer()
    $scope.observations = []
    window.o = Observation

    DS.find('viewState', $stateParams.dataSetId).then((viewState) ->
      DS.loadRelations('viewState', viewState, ['observation']).then((viewState) ->
        $scope.observations = viewState.observations
        $scope.observationsLoading.resolve()
      )
    )

    $scope.states =
      is_renaming: false
      is_discussing: false

    # Expand and retract group channels
    $scope.toggleGroup = (channel) -> toggleExpandRetract(channel)

    $scope.addChart = ->
      @current_data_set.addChart()

    $scope.logDataset = ->
      console.log(@current_data_set)
      console.log(angular.toJson(@current_data_set.serialize()))

    $scope.saveDataset = ->
      ViewState.update(
        { id: $scope.current_data_set.id },
        $scope.current_data_set.serialize()
      )
      console.log('saving')

    $scope.deleteDataset = ->
      dataset_id = $scope.current_data_set.id
      ViewState.delete({ id: dataset_id })
        .$promise
        .then(->
          window.s = $scope
          $scope.$parent.data_sets = $scope.$parent.data_sets.filter((ds) -> ds.id isnt dataset_id)
          $scope.$state.go('data-sets')
        )

    $scope.saveRenaming = ->
      $scope.current_data_set.title = $scope.temporary_data_set.title
      $scope.states.is_renaming = false

    $scope.cancelRenaming = ->
      $scope.temporary_data_set.title = $scope.current_data_set.title
      $scope.states.is_renaming = false

#   as seen here:
#   http://stackoverflow.com/questions/16947771/how-do-i-ignore-the-initial-load-when-watching-model-changes-in-angularjs
    initializing = true
    afterInitialization = (callback) ->
      if initializing
        $timeout(()-> initializing = false)
      else
        callback()

    $scope.$watch(
      'current_data_set.serialize()'
      () -> afterInitialization($scope.saveDataset)
      true
    )

    # full list of series

    # wait for the promise to succesfully finish
    SeriesService.findAll().then(
      (data) ->
        $scope.seriesList = data
    )

    $scope.joinAttributes = (attributes) ->
      attributesList = ''
      angular.forEach(attributes, (value, key) ->
        attributesList += key + ':' + value + ', '
      )
      return attributesList

#    TODO: implement filtering on the serverside
    $scope.querySeriesList = (typed) ->

      matcher = RegExp(typed, 'i')
      filteredSeries = []

#     search seriesList for matching items
      angular.forEach($scope.seriesList, (item, i) ->
        seriesTerms = item.key + '|' + item.tags.join('|') + $scope.joinAttributes(item.attributes)

        if matcher.test(seriesTerms)
          # used to control exhibition at autocomplete
          item.hasTags = item.tags.length > 0
          item.hasAttributes = $scope.joinAttributes(item.attributes).length > 0

          # add item to autocomplete list
          filteredSeries.push(item)
      )

      return filteredSeries

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "retracted" then "expanded" else "retracted")
])
