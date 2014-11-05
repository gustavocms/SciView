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
