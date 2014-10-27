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
    '$compile'
    ($timeout, $window, $compile) ->
        restrict: 'A'
        link: (scope, element, attributes) ->
            $timeout ->
                dataSetsWidth = element[0].offsetWidth
                windowWidth = $window.innerWidth
                console.log(element[0].offsetWidth)
                if `dataSetsWidth*1.68 >= windowWidth`
                    element.addClass('shrink')
                    console.log(scope, element, attributes)
                    # $compile(element)(scope)            
            , 200

])