class TimeAgoInWords
  constructor: (time) ->
    @time    = new Date(time)
    @seconds = @time.getTime() / 1000

  thresholds:
    minute: 60
    hour: 3600
    day: 86400
    month: 2592000
    year: 31557600

  time_ago_in_words: ->
    try
      diff = @_difference_in_seconds()
      (switch
        when diff < @thresholds.minute then @_seconds
        when diff < @thresholds.hour then @diff_for('minute')
        when diff < @thresholds.day then @diff_for('hour')
        when diff < @thresholds.month then @diff_for('day')
        when diff < @thresholds.year then @diff_for('month')
        else @diff_for('year')
      )(diff)
    catch error
      console.log(error)
      return @seconds

  diff_for: (threshold_name) ->
    (diff) =>
      multiples = Math.round(parseFloat(diff) / (@thresholds[threshold_name]))
      str = if multiples > 1 then "#{threshold_name}s" else threshold_name
      "#{multiples} #{str} ago"


  _seconds: (_) -> "Less than 1 minute ago"

  _difference_in_seconds: ->
    @_now() - @seconds

  _now: ->
    (new Date()).getTime() / 1000

angular.module('sv.ui.filters', [])
  .filter('timeAgo', ->
    (input) ->
      (new TimeAgoInWords (input)).time_ago_in_words()
  )
  
