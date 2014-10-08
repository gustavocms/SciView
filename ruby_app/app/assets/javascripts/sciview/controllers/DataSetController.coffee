module = angular.module("sv.ui.controllers")

module.controller('DataSetController', [
  '$scope'
  '$stateParams'
  '$timeout'
  'ViewState'
  'SeriesService'
  'mySocket'
  ($scope, $stateParams, $timeout, ViewState, SeriesService, mySocket) ->

#  waits for the parent loading to finish
    $scope.deferredDatasetsLoading.promise.then ->

  #   find the correct dataset in parent's scope
      filteredDS = $scope.$parent.data_sets.filter (ds) ->
        ds.id.toString() == $stateParams.dataSetId

      $scope.setCurrentDataSet(filteredDS[0])
      $scope.registerSocketWatchers()

  #   used to manage changes that may be reverted
      $scope.temporary_data_set =
        title: $scope.current_data_set.title

    $scope.states =
      is_renaming: false

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

    $scope.setCurrentDataSet = (dataset) ->
      $scope.current_data_set = dataset
      $scope.registerSocketWatchers()

    $scope.saveRenaming = ->
      $scope.current_data_set.title = $scope.temporary_data_set.title
      $scope.states.is_renaming = false

    $scope.cancelRenaming = ->
      $scope.temporary_data_set.title = $scope.current_data_set.title
      $scope.states.is_renaming = false

    $scope.registerSocketWatchers = ->
#      mySocket.emit('resetWatchers')
#      for seriesName in $scope.current_data_set.seriesKeys()
#        mySocket.emit('watchSeries', seriesName)

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
    SeriesService.findAll()
    SeriesService.bindAll($scope, 'seriesList', {})

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
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")
])
