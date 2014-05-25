round_down_to_5_minutes = (time) -> time.subtract('minutes', time.minute() % 5)

mincha_time = (zmanim, hebrew_date) ->
  sunset = moment(zmanim.sunset)
  if hebrew_date.isYomKippur()
    round_down_to_5_minutes(sunset.subtract('hour', 3))
  else
    sunset.subtract('minutes', 18)

window.mincha = (zmanim, hebrew_date) ->
  time = mincha_time(zmanim, hebrew_date)
  if time then time.format('h:mm') else ''
