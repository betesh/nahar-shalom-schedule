time_format = (t) -> t.format("h:mm:ss")

show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> $(".#{day} .#{event}").hasClass('hidden') for event in events
has_no_event = (day) -> event_array(day).indexOf(false) < 0

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

write_schedule = (day_iterator) ->
  day_iterator.day('Sunday')
  for day in moment.weekdays()[0,6]
    $(".#{day}").removeClass('hidden')
    $(".#{day} .selihot").addClass('hidden').html('')
    $(".#{day} .placeholder").addClass('hidden')
    $(".#{day} .date").html(day_iterator.format("D MMM"))
    date = day_iterator.toDate()
    hebrew_date = new HebrewDate(date)
    show_event(day, event, hebrew_date) for event in events
    if hebrew_date.isYomTov() || hebrew_date.isYomKippur()
      $(".#{day}").addClass('hidden')
    else
      sunrise = moment(SunCalc.getTimes(date, window.config.latitude, window.config.longitude).sunrise)
      $(".#{day} .amidah").html(time_format(sunrise))
      $(".#{day} .yishtabach").html(time_format(sunrise.subtract('minutes', 8)))
      $(".#{day} .hodu").html(time_format(sunrise.subtract('minutes', if hebrew_date.isMoed() then 12 else 11)))
      $(".#{day} .korbanot").html(time_format(sunrise.subtract('minutes', 16)))
      if hebrew_date.is10DaysOfTeshuvah()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract('minutes', 56)))
      if hebrew_date.isElul() && !hebrew_date.isRoshChodesh()
        $(".#{day} .selihot").removeClass('hidden').html(time_format(sunrise.subtract('minutes', 50)))
    day_iterator.add('days', 1)
  $(".header .event")[show_if($('.one_day .event').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .placeholder")[show_if(has_no_event(day))]('hidden') for day in moment.weekdays()[0,6]) unless $(".header .event").hasClass('hidden')
  $(".header .selihot")[show_if($('.one_day .selihot').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .selihot").removeClass('hidden') for day in moment.weekdays()[0,6]) unless $(".header .selihot").hasClass('hidden')

$ ->
  window.events = (e.className.replace(/hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.sunday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(moment().format("YYYY-MM-DD")).change()
