show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> ($(".one_day.#{day} .#{event}").not(".hidden").length > 0) for event in events
has_no_event = (day) -> true not in event_array(day)

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

shaharit_is_fixed_at = (day, hour, minute) ->
  time = moment().hour(hour).minute(minute)
  $(".#{day} .korbanot").html(time.format("h:mm"))
  $(".#{day} .hodu").html(time.add(15, 'minutes').format("h:mm"))
  $(".#{day} .yishtabach").html('')
  $(".#{day} .amidah").html('')

catching_errors = (topic, fn) ->
  if "localhost" == window.location.hostname
    fn()
  else
    try
      fn()
    catch e
      Raven.captureException(e, tags: { date: day_iterator.toDate(), topic: topic })

write_schedule = (day_iterator) ->
  $('.start-hidden').addClass('hidden')
  $('.start-shown').removeClass('hidden')
  $(".one_day .selihot").html('')
  $(".one_day .omer").html('')
  day_iterator.day('Saturday')
  hebrew_date = null
  for day in moment.weekdays().reverse()
    catching_errors 'Morning', ->
      $(".#{day} .date").html(day_iterator.format("D MMM"))
      hebrew_date = new HebrewDate(day_iterator.toDate())
      $(".#{day} .hebrew_date").html("#{hebrew_date.staticHebrewMonth.name} #{hebrew_date.dayOfMonth}")
      show_event(day, event, hebrew_date) for event in events
      if hebrew_date.isYomKippur()
        shaharit_is_fixed_at(day, 7, 0)
      else if hebrew_date.is1stDayOfShabuot()
        new Vatikin(day_iterator, hebrew_date).updateDOM()
      else if hebrew_date.is1stDayOfPesach() || hebrew_date.is2ndDayOfPesach()
        shaharit_is_fixed_at(day, 8, 45)
      else if hebrew_date.isYomTov() || hebrew_date.isShabbat()
        # TODO: Shofar 2:30 after Hodu on Rosh Hashana that isn't Shabbat
        shaharit_is_fixed_at(day, 7, 45)
      else
        new Vatikin(day_iterator, hebrew_date).updateDOM()
    catching_errors 'Afternoon', ->
      afternoon = mincha_and_arbit(day_iterator)
      $(".#{day} .mincha").html(afternoon.mincha)
      $(".#{day} .arbit").html(afternoon.arbit)
    $(".#{day} .omer").removeClass('hidden').html("#{day_iterator.format('ddd')}. night: <b>#{hebrew_date.omer().tonight}</b>") if hebrew_date.omer()? and hebrew_date.omer().tonight
    day_iterator.subtract(1, 'days')
  $(".header .event")[show_if($('.one_day .event').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .placeholder")[show_if(has_no_event(day))]('hidden') for day in moment.weekdays()) unless $(".header .event").hasClass('hidden')
  for column in ['selihot', 'omer']
    $(".header .#{column}")[show_if($(".one_day .#{column}").not('.hidden').length > 0)]('hidden')
    ($(".#{day} .#{column}").removeClass('hidden') for day in moment.weekdays()) unless $(".header .#{column}").hasClass('hidden')

$ ->
  window.events = (e.className.replace(/start-hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.Saturday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(moment().add(12, 'hours').format("YYYY-MM-DD")).change()
