module = angular.module('sv.ui.services')

module.service "Alerts", ($rootScope) ->
  Alerts = {}
  Alerts.pushMessage = (text, type) ->
    console.log("alert", text)
    $rootScope.$broadcast('alert', { 
      text: text
      type: type
      }
    )

  Alerts