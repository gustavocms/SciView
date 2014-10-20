module = angular.module('sv.ui.directives')

module.directive('hoverIntent', [
    '$timeout'
    ($timeout) ->
        restrict: 'A'
        link: (scope, element, attributes) ->
            # hoverIntentPromise
            element.bind('mouseenter', (event) ->
                delay = scope.$eval(attributes.hoverIntentDelay)
                if `delay === undefined`
                    delay = 1000

                hoverIntentPromise = $timeout ->
                    scope.$eval(attributes.hoverIntent, { $event: event } )
                , delay
            )
            element.bind('mouseleave', ->
                $timeout.cancel(hoverIntentPromise)
            )
])

module.directive('tabs', [
    '$timeout'
    '$window'
    ($timeout, $window) ->
        restrict: 'A'
        link: (scope, element, attributes) ->
            $timeout ->
                console.log(element[0].offsetWidth)
            , 1
            # console.log(element[0].offsetWidth)
            console.log("Window", $window.innerWidth)
])