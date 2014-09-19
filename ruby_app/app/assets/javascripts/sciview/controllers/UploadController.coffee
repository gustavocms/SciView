app = angular.module("sciview")

app.controller "UploadController", [
  "$scope"
  ($scope) ->
    $scope.uploads = []
    index = 0
    upload_items = [
      {
        name: "LAUNCH_FILE_3s"
        status:
          upload: false
      }
      {
        name: "TEST_LAUNCH"
        status:
          upload: false
      }
      {
        name: "TEST_3"
        status:
          upload: false
      }
    ]
    $scope.choseFile = ->
      $scope.uploads.push upload_items[index]
      index++
      return

    $scope.uploadItem = (item) ->
      item.status.upload = true
      return

    $scope.stopUpload = (item) ->
      $scope.uploads.splice item, 1
      return
]
