//= require ../vendor/flipclock
//= require ../site/sunrise

redirect = -> window.location.href = "/index.html"

secondsToSunrise = ->
  today = moment().startOf('day')
  sunrise = new Sunrise(today).get()
  sunrise = new Sunrise(today.add(1, 'days')).get() if moment().isAfter(sunrise)
  sunrise.diff(moment(), 'seconds')

countDown = (clock) ->
  seconds = secondsToSunrise()
  clock.setTime(seconds)
  console.log "Resetting sunrise clock, with #{seconds} seconds left" if console?
  if seconds > 10
    setTimeout((-> countDown(clock)), 1e4)
  else
    setTimeout(redirect, (seconds + 4) * 1000)

$ ->
  clock = $('.countdown-to-sunrise').FlipClock 60, countdown:true
  countDown(clock)
