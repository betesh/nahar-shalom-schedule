time_format = (t) -> t.format("h:mm:ss")

show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> $(".#{day} .#{event}").hasClass('hidden') for event in events
has_no_event = (day) -> event_array(day).indexOf(false) < 0

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

shaharit_is_fixed_at = (day, hour, minute) ->
  time = moment().hour(hour).minute(minute)
  $(".#{day} .korbanot").html(time.format("h:mm"))
  $(".#{day} .hodu").html(time.add('minutes', 15).format("h:mm"))
  $(".#{day} .yishtabach").html('')
  $(".#{day} .amidah").html('')

write_schedule = (day_iterator) ->
  $('.mosaei-yom-tob').addClass('hidden') unless $('.mosaei-yom-tob').hasClass('hidden')
  unless $('.ereb-9-ab').hasClass('hidden')
    $('.ereb-9-ab').addClass('hidden')
    $('.not-ereb-9-ab').removeClass('hidden')
  $('.one_hadlakat_nerot').addClass('hidden')
  day_iterator.day('Saturday')
  for day in moment.weekdays().reverse()
    $(".#{day} .selihot").addClass('hidden').html('')
    $(".#{day} .placeholder").addClass('hidden')
    $(".#{day} .date").html(day_iterator.format("D MMM"))
    hebrew_date = new HebrewDate(day_iterator.toDate())
    show_event(day, event, hebrew_date) for event in events
    if hebrew_date.isYomKippur() || hebrew_date.isRoshHashana()
      shaharit_is_fixed_at(day, 7, 0)
    else if hebrew_date.is1stDayOfShabuot()
      sunrise = new Sunrise(day_iterator).get()
      $(".#{day} .amidah").html(time_format(sunrise))
      $(".#{day} .yishtabach").html(time_format(sunrise.subtract('minutes', 17)))
      $(".#{day} .hodu").html(time_format(sunrise.subtract('minutes', 26)))
      $(".#{day} .korbanot").html(time_format(sunrise.subtract('minutes', 15)))
    else if hebrew_date.isYomTov() || hebrew_date.isShabbat()
      shaharit_is_fixed_at(day, 7, 45)
    else
      sunrise = new Sunrise(day_iterator).get()
      $(".#{day} .amidah").html(time_format(sunrise))
      $(".#{day} .yishtabach").html(time_format(sunrise.subtract('minutes', 8)))
      $(".#{day} .hodu").html(time_format(sunrise.subtract('minutes', if hebrew_date.isMoed() then 12 else 11)))
      $(".#{day} .korbanot").html(time_format(sunrise.subtract('minutes', 16)))
      if hebrew_date.is10DaysOfTeshuvah()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract('minutes', 56)))
      if hebrew_date.isElul() && !hebrew_date.isRoshChodesh()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract('minutes', 50)))
    afternoon = mincha_and_arbit(day_iterator, hebrew_date)
    $(".#{day} .mincha").html(afternoon.mincha)
    $(".#{day} .arbit").html(afternoon.arbit)
    day_iterator.subtract('days', 1)
  $(".header .event")[show_if($('.one_day .event').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .placeholder")[show_if(has_no_event(day))]('hidden') for day in moment.weekdays()) unless $(".header .event").hasClass('hidden')
  $(".header .selihot")[show_if($('.one_day .selihot').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .selihot").removeClass('hidden') for day in moment.weekdays()) unless $(".header .selihot").hasClass('hidden')

$ ->
  window.events = (e.className.replace(/hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.sunday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(moment().format("YYYY-MM-DD")).change()

$ ->
  time_now = moment().startOf('day')
  sunrise = new Sunrise(time_now).get()
  sunrise = new Sunrise(time_now.add('days', 1)).get() if moment().isAfter(sunrise)
  time_to_sunrise = sunrise.diff(moment(), 'seconds')
  clock = $('.countdown-to-sunrise').FlipClock time_to_sunrise, countdown:true
