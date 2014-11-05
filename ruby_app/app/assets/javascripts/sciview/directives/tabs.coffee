module = angular.module('sv.ui.directives')

module.directive('tabs', [
  '$window'
  ($window) ->
    restrict: 'A'
    link: (scope, element, attributes) ->
      scope.$watch(
        () ->
          element[0].childElementCount
        () ->
          dataSetsWidth = element[0].offsetWidth
          windowWidth = $window.innerWidth
          console.log(element[0].offsetWidth)
          if `dataSetsWidth*1.68 >= windowWidth`
            element.addClass('shrink')
            console.log('addClass')
          else
            element.removeClass('shrink')
            console.log('removeClass')
      )
])