get_time_to_sunrise = ->
  time_now = moment().startOf('day')
  sunrise = new Sunrise(time_now).get()
  sunrise = new Sunrise(time_now.add('days', 1)).get() if moment().isAfter(sunrise)
  sunrise.diff(moment(), 'seconds')

$ ->  $('.countdown-to-sunrise').FlipClock get_time_to_sunrise(), countdown:true
