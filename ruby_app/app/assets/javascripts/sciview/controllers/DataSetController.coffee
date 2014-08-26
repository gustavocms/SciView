app = angular.module('sciview')

app.controller('DataSetController', [
  '$scope'
  '$stateParams'
  '$timeout'
  'ViewState'
  ($scope, $stateParams, $timeout, ViewState) ->

#   find the correct dataset in parent's scope
    filteredDS = $scope.$parent.data_sets.filter (ds) ->
      ds.id.toString() == $stateParams.dataSetId

    $scope.current_data_set = filteredDS[0]

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

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")
])
