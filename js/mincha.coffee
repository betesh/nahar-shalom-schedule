round_down_to_5_minutes = (time) -> time.subtract('minutes', time.minute() % 5)
recent_hadlakat_nerot = null;

display_hadlakat_nerot = (date) ->
  row = $('.one_hadlakat_nerot.hidden:last').removeClass('hidden')
  row.find('.dow').html(date.format('dddd'))
  row.find('.date').html(date.format('D MMM'))
  row.find('.time')

set_hakochabim = (zmanim) -> moment(zmanim.set_hakochabim).format('h:mm')

after_set_hakochabim = (hebrew_date, zmanim) -> "After #{if hebrew_date.isShabbat() then 'שַׁבָּת ends' else set_hakochabim(zmanim)}"

hadlakat_nerot_is_after_set_hakochabim = (date, hebrew_date, zmanim) -> display_hadlakat_nerot(date).html(after_set_hakochabim(hebrew_date, zmanim)) if hebrew_date.is1stDayOfYomTob() && !hebrew_date.isErebShabbat()

portion_of_day = (zmanim, ratio) ->
  sunrise = moment(zmanim.sunrise)
  sunrise.add('minutes', moment(zmanim.sunset).diff(sunrise, 'minutes') * ratio)

plag = (zmanim) -> portion_of_day(zmanim, 43.0/48.0)

samuch_lemincha_ketana = (zmanim) -> portion_of_day(zmanim, 0.75)

begin_seudat_shelishit_samuch_lemincha_ketana = (hebrew_date, zmanim) ->
  start_eating_at = samuch_lemincha_ketana(zmanim)
  $('.begin-seudat-shelishit-before').html(start_eating_at.format('h:mm')) if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
  start_eating_at

show_mosaei_yom_tob = (date, zmanim) ->
  $('.mosaei-yom-tob').removeClass('hidden').find('.date').html(moment.weekdays()[date.weekday()])
  $('.yom-tob-ends').html(set_hakochabim(zmanim))

mincha_time = (zmanim, hebrew_date) ->
  sunset = moment(zmanim.sunset).subtract('second', 30)
  if hebrew_date.isShabbat()
    $('.rabbenu-tam').html(moment(sunset).add('minute', 73).format('h:mm'))
    $('.shabbat-ends').html(set_hakochabim(zmanim))
    $('.begin-seudat-shelishit-before').html(sunset.format('h:mm')) unless hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()
  if hebrew_date.isErebShabbat() || hebrew_date.isErebYomTob() || hebrew_date.isErebYomKippur()
    recent_hadlakat_nerot = moment(sunset).subtract('minute', 19)
    display_hadlakat_nerot(recent_hadlakat_nerot).html(if hebrew_date.isShabbat() then after_set_hakochabim(hebrew_date, zmanim) else recent_hadlakat_nerot.format('h:mm'))
  if hebrew_date.isYomKippur()
    mincha: round_down_to_5_minutes(sunset.subtract('hours', 3)),
    arbit: moment(zmanim.set_hakochabim).add('minutes', 10)
  else if hebrew_date.isRoshHashana()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date, zmanim)
    mincha: (round_down_to_5_minutes(if hebrew_date.isShabbat() then begin_seudat_shelishit_samuch_lemincha_ketana(hebrew_date, zmanim).subtract('hours', 2) else sunset.subtract('hours', 1))),
    arbit: if hebrew_date.isShabbat() then sunset else (if hebrew_date.is1stDayOfYomTob() || hebrew_date.isErebShabbat() then null else (show_mosaei_yom_tob(sunset, zmanim) && null))
    ### 2nd null is @TODO: Mosa'ei YT ###
  else if hebrew_date.is9Ab()
    mincha: moment(sunset).subtract('minutes', 40), arbit: sunset
  else if hebrew_date.isTaanitEster()
    mincha: moment(sunset).subtract('minutes', 30), arbit: sunset
  else if hebrew_date.isTaanit()
    if hebrew_date.isErebShabbat()
      mincha: moment(sunset).subtract('minutes', 45)
    else
      mincha: moment(sunset).subtract('minutes', 25), arbit: sunset
  else if hebrew_date.isErebYomKippur()
    mincha: moment(sunset).hour(14).minute(30), arbit: sunset.subtract('minutes', 45)
  else if hebrew_date.isEreb9Ab()
    if hebrew_date.isShabbat()
      $('.ereb-9-ab').removeClass('hidden')
      $('.not-ereb-9-ab').addClass('hidden')
      mincha: round_down_to_5_minutes(moment(sunset).subtract('minutes', 100)), arbit: sunset.add('minutes', 90)
    else
      mincha: moment(sunset).subtract('minutes', 40), arbit: sunset
  else if hebrew_date.isPurim()
    {}
  else if hebrew_date.is6thDayOfPesach()
    mincha: sunset.hour(18).minute(30)
  else if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date, zmanim)
    mincha: round_down_to_5_minutes(begin_seudat_shelishit_samuch_lemincha_ketana(hebrew_date, zmanim).subtract('hours', 1)),
    arbit: sunset
    ### 2nd null is @TODO: YT on Mosa'ei Shabbat ###
  else if hebrew_date.isShabbat()
    mincha: round_down_to_5_minutes(moment(sunset).subtract('minutes', 45)), arbit: moment(zmanim.set_hakochabim).add('minutes', 10)
  else if hebrew_date.is7thDayOfPesach() || hebrew_date.is1stDayOfShabuot() || (hebrew_date.isYomTob() && hebrew_date.isErebShabbat())
    display_hadlakat_nerot(sunset).html("Before Kiddush<br><b>Eat from all cooked<br>foods before #{sunset.format('h:mm')}</b>") unless hebrew_date.isErebShabbat()
    earliest_arbit = plag(zmanim)
    if earliest_arbit.isBefore(moment(earliest_arbit).hour(18).minute(15))
      mincha: moment(earliest_arbit).hour(17).minute(45), arbit: earliest_arbit.hour(18).minute(15)
    else
      mincha: round_down_to_5_minutes(moment(earliest_arbit).subtract('minutes', 30)), arbit: earliest_arbit
  else if hebrew_date.isYomTob()
    hadlakat_nerot_is_after_set_hakochabim(sunset, hebrew_date, zmanim)
    mincha: round_down_to_5_minutes(sunset.subtract('minutes', 25)), arbit: if hebrew_date.is1stDayOfYomTob() then null else (show_mosaei_yom_tob(sunset, zmanim) && null)
    ### 2nd null is @TODO: Mosa'ei YT ###
  else if hebrew_date.isErebYomTob()
    mincha: sunset.subtract('minutes', if hebrew_date.isErebShabbat() then 33 else 19)
  else if hebrew_date.isErebShabbat()
    mincha: (if sunset.hour() < 19 || (19 == sunset.hour() && sunset.minute() < 3) then sunset.subtract('minutes', 33) else sunset.hour(18).minute(30))
  else
    mincha: recent_hadlakat_nerot, arbit: sunset

window.mincha_and_arbit = (day_iterator, hebrew_date) ->
  zmanim = SunCalc.getTimes(moment(day_iterator).toDate().setHours(12), window.config.latitude, window.config.longitude)
  times = mincha_time(zmanim, hebrew_date)
  (times[prayer] = if times[prayer] then times[prayer].format('h:mm') else '') for prayer in ['mincha', 'arbit']
  times
