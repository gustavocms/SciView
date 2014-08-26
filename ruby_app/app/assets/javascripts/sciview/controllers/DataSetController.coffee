app = angular.module('sciview')

app.controller('DataSetController', [
  '$scope'
  '$stateParams'
  'ViewState'
  ($scope, $stateParams, ViewState) ->

#   find the correct dataset in parent's scope
    filteredDS = $scope.$parent.data_sets.filter (ds) ->
      ds.id.toString() == $stateParams.dataSetId

    $scope.current_data_set = filteredDS[0]

#   used to manage changes that may be reverted
    $scope.temporary_data_set = angular.copy($scope.current_data_set)

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
      $scope.saveDataset()

    $scope.cancelRenaming = ->
      $scope.temporary_data_set.title = $scope.current_data_set.title
      $scope.states.is_renaming = false

    toggleExpandRetract = (obj) ->
      obj.state = (if obj.state is "is-retracted" then "is-expanded" else "is-retracted")
])
