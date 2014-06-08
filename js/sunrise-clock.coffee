get_time_to_sunrise = ->
  time_now = moment().startOf('day')
  sunrise = new Sunrise(time_now).get()
  sunrise = new Sunrise(time_now.add('days', 1)).get() if moment().isAfter(sunrise)
  sunrise.diff(moment(), 'seconds')

set_countdown_clock_repeatedly = (clock) ->
  clock.setTime(get_time_to_sunrise())
  setTimeout((-> set_countdown_clock_repeatedly(clock)), 3e+4)

$ -> set_countdown_clock_repeatedly($('.countdown-to-sunrise').FlipClock get_time_to_sunrise(), countdown:true)
