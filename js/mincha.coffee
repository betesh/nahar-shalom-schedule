round_down_to_5_minutes = (time) -> time.subtract('minutes', time.minute() % 5)
recent_hadlakat_nerot = null;

display_hadlakat_nerot = (date) ->
  row = $('.one_hadlakat_nerot.hidden:last').removeClass('hidden')
  row.find('.dow').html(date.format('dddd'))
  row.find('.date').html(date.format('D MMM'))
  row.find('.time')

set_hakochabim = (hebrew_date) -> if hebrew_date.isShabbat() then 'After שַׁבָּת ends' else 'After &nbsp;&nbsp;&nbsp;&nbsp;:'

hadlakat_nerot_is_after_set_hakochabim = (date, hebrew_date) -> display_hadlakat_nerot(date).html(set_hakochabim(hebrew_date)) if hebrew_date.is1stDayOfYomTob() && !hebrew_date.isErebShabbat()

portion_of_day = (zmanim, ratio) ->
  sunrise = moment(zmanim.sunrise)
  sunrise.add('minutes', moment(zmanim.sunset).diff(sunrise, 'minutes') * ratio)

plag = (zmanim) -> portion_of_day(zmanim, 43.0/48.0)

samuch_lemincha_ketana = (zmanim) -> portion_of_day(zmanim, 0.75)

begin_seudat_shelishit_samuch_lemincha_ketana = (hebrew_date, zmanim) ->
  start_eating_at = samuch_lemincha_ketana(zmanim)
  $('.begin-seudat-shelishit-before').html(start_eating_at.format('h:mm')) if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
  start_eating_at

mincha_time = (zmanim, hebrew_date) ->
  sunset = moment(zmanim.sunset).subtract('second', 30)
  if hebrew_date.isShabbat()
    $('.rabbenu-tam').html(moment(sunset).add('minute', 73).format('h:mm'))
    $('.begin-seudat-shelishit-before').html(sunset.format('h:mm')) unless hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()
  if hebrew_date.isErebShabbat() || hebrew_date.isErebYomTob() || hebrew_date.isErebYomKippur()
    recent_hadlakat_nerot = moment(sunset).subtract('minute', 19)
    display_hadlakat_nerot(recent_hadlakat_nerot).html(if hebrew_date.isShabbat() then set_hakochabim(hebrew_date) else recent_hadlakat_nerot.format('h:mm'))
  if hebrew_date.isYomKippur()
    round_down_to_5_minutes(sunset.subtract('hours', 3))
  else if hebrew_date.isRoshHashana()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    round_down_to_5_minutes(if hebrew_date.isShabbat() then begin_seudat_shelishit_samuch_lemincha_ketana(hebrew_date, zmanim).subtract('hours', 2) else sunset.subtract('hours', 1))
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
      $('.ereb-9-ab').removeClass('hidden')
      $('.not-ereb-9-ab').addClass('hidden')
      round_down_to_5_minutes(sunset.subtract('minutes', 100))
    else
      sunset.hour(18).minute(0)
  else if hebrew_date.isPurim()
    ### @TODO: Purim ###
  else if hebrew_date.is6thDayOfPesach()
    sunset.hour(18).minute(30)
  else if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    round_down_to_5_minutes(begin_seudat_shelishit_samuch_lemincha_ketana(hebrew_date, zmanim).subtract('hours', 1))
  else if hebrew_date.isShabbat()
    round_down_to_5_minutes(sunset.subtract('minutes', 45))
  else if hebrew_date.is7thDayOfPesach() || hebrew_date.is1stDayOfShabuot() || (hebrew_date.isYomTob() && hebrew_date.isErebShabbat())
    display_hadlakat_nerot(sunset).html("Before Kiddush<br><b>Eat from all cooked<br>foods before #{sunset.format('h:mm')}</b>") unless hebrew_date.isErebShabbat()
    time = round_down_to_5_minutes(plag(zmanim).subtract('minutes', 25))
    if time.hour() < 17 || (17 == time.hour() && time.minute() < 45) then time.hour(17).minute(45) else time
  else if hebrew_date.isYomTob()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date)
    round_down_to_5_minutes(sunset.subtract('minutes', 25))
  else if hebrew_date.isErebYomTob()
    sunset.subtract('minutes', if hebrew_date.isErebShabbat() then 33 else 19)
  else if hebrew_date.isErebShabbat()
    if sunset.hour() < 19 || (19 == sunset.hour() && sunset.minute() < 3) then sunset.subtract('minutes', 33) else sunset.hour(18).minute(30)
  else
    recent_hadlakat_nerot

window.mincha = (day_iterator, hebrew_date) ->
  zmanim = SunCalc.getTimes(moment(day_iterator).toDate().setHours(12), window.config.latitude, window.config.longitude)
  time = mincha_time(zmanim, hebrew_date)
  if time then time.format('h:mm') else ''
