time_format = (t) -> t.format("h:mm:ss")

show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> $(".#{day} .#{event}").hasClass('hidden') for event in events
has_no_event = (day) -> event_array(day).indexOf(false) < 0

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

shaharit_is_fixed_at = (day, hour, minute) ->
  time = moment().hour(hour).minute(minute)
  $(".#{day} .korbanot").html(time.format("h:mm"))
  $(".#{day} .hodu").html(time.add(15, 'minutes').format("h:mm"))
  $(".#{day} .yishtabach").html('')
  $(".#{day} .amidah").html('')

write_schedule = (day_iterator) ->
  $('.start-hidden').addClass('hidden')
  $('.start-shown').removeClass('hidden')
  $(".one_day .selihot").html('')
  day_iterator.day('Saturday')
  for day in moment.weekdays().reverse()
    $(".#{day} .date").html(day_iterator.format("D MMM"))
    hebrew_date = new HebrewDate(day_iterator.toDate())
    show_event(day, event, hebrew_date) for event in events
    if hebrew_date.isYomKippur()
      shaharit_is_fixed_at(day, 7, 0)
    else if hebrew_date.is1stDayOfShabuot()
      sunrise = new Sunrise(day_iterator).get()
      $(".#{day} .amidah").html(time_format(sunrise))
      $(".#{day} .yishtabach").html(time_format(sunrise.subtract(17, 'minutes')))
      $(".#{day} .hodu").html(time_format(sunrise.subtract(26, 'minutes')))
      $(".#{day} .korbanot").html(time_format(sunrise.subtract(15, 'minutes')))
    else if hebrew_date.isYomTov() || hebrew_date.isShabbat()
      # TODO: Shofar 2:30 after Hodu on Rosh Hashana that isn't Shabbat
      shaharit_is_fixed_at(day, 7, 45)
    else
      sunrise = new Sunrise(day_iterator).get()
      $(".#{day} .amidah").html(time_format(sunrise))
      $(".#{day} .yishtabach").html(time_format(sunrise.subtract(8, 'minutes')))
      $(".#{day} .hodu").html(time_format(sunrise.subtract((if hebrew_date.isMoed() then 12 else 11), 'minutes')))
      $(".#{day} .korbanot").html(time_format(sunrise.subtract(16, 'minutes')))
      if hebrew_date.is10DaysOfTeshuvah()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract(56, 'minutes')))
      if hebrew_date.isElul() && !hebrew_date.isRoshChodesh()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract(50, 'minutes')))
    afternoon = mincha_and_arbit(day_iterator, hebrew_date)
    $(".#{day} .mincha").html(afternoon.mincha)
    $(".#{day} .arbit").html(afternoon.arbit)
    day_iterator.subtract(1, 'days')
  $(".header .event")[show_if($('.one_day .event').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .placeholder")[show_if(has_no_event(day))]('hidden') for day in moment.weekdays()) unless $(".header .event").hasClass('hidden')
  $(".header .selihot")[show_if($('.one_day .selihot').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .selihot").removeClass('hidden') for day in moment.weekdays()) unless $(".header .selihot").hasClass('hidden')

$ ->
  window.events = (e.className.replace(/start-hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.sunday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(moment().add(12, 'hours').format("YYYY-MM-DD")).change()
