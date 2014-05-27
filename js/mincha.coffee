round_down_to_5_minutes = (time) -> time.subtract('minutes', time.minute() % 5)
recent_hadlakat_nerot = null;

display_hadlakat_nerot = (date) ->
  row = $('.one_hadlakat_nerot.hidden:last').removeClass('hidden')
  row.find('.dow').html(date.format('dddd'))
  row.find('.date').html(date.format('D MMM'))
  row.find('.time')

set_hakochabim = -> 'After &nbsp;&nbsp;&nbsp;&nbsp;:'

hadlakat_nerot_is_after_set_hakochabim = (date, hebrew_date) -> display_hadlakat_nerot(date).html(set_hakochabim()) if hebrew_date.is1stDayOfYomTob() && !hebrew_date.isErebShabbat()

mincha_time = (zmanim, hebrew_date) ->
  sunset = moment(zmanim.sunset)
  if hebrew_date.isErebShabbat() || hebrew_date.isErebYomTob() || hebrew_date.isErebYomKippur()
    recent_hadlakat_nerot = moment(sunset).subtract('minute', 19)
    display_hadlakat_nerot(recent_hadlakat_nerot).html(if hebrew_date.isShabbat() then set_hakochabim() else recent_hadlakat_nerot.format('h:mm'))
  if hebrew_date.isYomKippur()
    round_down_to_5_minutes(sunset.subtract('hours', 3))
  else if hebrew_date.isRoshHashana()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    round_down_to_5_minutes(sunset.subtract('hours', 1))
  else if hebrew_date.is9Ab()
    sunset.subtract('minutes', 40)
  else if hebrew_date.isTaanitEster()
    sunset.subtract('minutes', 30)
  else if hebrew_date.isTaanit()
    sunset.subtract('minutes', if hebrew_date.isErebShabbat() then 45 else 25)
  else if hebrew_date.isErebYomKippur()
    sunset.hour(14).minute(30)
  else if hebrew_date.isEreb9Ab()
    if hebrew_date.isShabbat()
      ### @TODO: 9 Ab on Shabbat ###
      null
    else
      sunset.hour(18).minute(0)
  else if hebrew_date.isPurim()
    ### @TODO: 9 Ab on Shabbat ###
  else if hebrew_date.is6thDayOfPesach()
    sunset.hour(18).minute(30)
  else if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    null
    ### @TODO: Ereb Yom Tob or Yom Tob on Shabbat ###
  else if hebrew_date.isShabbat()
    round_down_to_5_minutes(sunset.subtract('minutes', 45))
  else if hebrew_date.is7thDayOfPesach() || hebrew_date.is1stDayOfShabuot() || (hebrew_date.isYomTob() && hebrew_date.isErebShabbat())
    sunrise = moment(zmanim.sunrise)
    plag = sunset.diff(sunrise, 'minutes') * 10.75 / 12
    display_hadlakat_nerot(sunset).html("Before Kiddush<br><b>Eat from all cooked<br>foods before #{sunset.format('h:mm')}</b>") unless hebrew_date.isErebShabbat()
    time = round_down_to_5_minutes(sunrise.add('minutes', plag).subtract('minutes', 25))
    if time.hour() < 17 || time.minute() < 45 then time.hour(17).minute(45) else time
  else if hebrew_date.isYomTob()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    round_down_to_5_minutes(sunset.subtract('minutes', 25))
  else if hebrew_date.isErebYomTob()
    sunset.subtract('minutes', if hebrew_date.isErebShabbat() then 33 else 19)
  else if hebrew_date.isErebShabbat()
    if sunset.hour() < 19 || sunset.minute() < 3 then sunset.subtract('minutes', 33) else sunset.hour(18).minute(30)
  else
    recent_hadlakat_nerot

window.mincha = (zmanim, hebrew_date) ->
  time = mincha_time(zmanim, hebrew_date)
  if time then time.format('h:mm') else ''
