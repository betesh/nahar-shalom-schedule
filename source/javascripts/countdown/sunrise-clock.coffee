//= require ../vendor/flipclock
//= require ../site/sunrise

get_time_to_sunrise = ->
  time_now = moment().startOf('day')
  sunrise = new Sunrise(time_now).get()
  sunrise = new Sunrise(time_now.add(1, 'days')).get() if moment().isAfter(sunrise)
  sunrise.diff(moment(), 'seconds')

set_countdown_clock_repeatedly = (clock) ->
  time_left = get_time_to_sunrise()
  clock.setTime(time_left)
  console.log "Resetting sunrise clock, with #{time_left} seconds left" if console?
  setTimeout((-> set_countdown_clock_repeatedly(clock)), 1e4) if time_left > 10

$ -> set_countdown_clock_repeatedly($('.countdown-to-sunrise').FlipClock get_time_to_sunrise(), countdown:true)
