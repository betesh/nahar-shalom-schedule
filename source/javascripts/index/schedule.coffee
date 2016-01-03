initialDate = ->
  initialDate = window.location.search.replace("?", "")
  initialDate = if initialDate.length > 0 then moment(initialDate, "YYYYMMDD").toDate() else (new Date())
  moment(initialDate).add(12, 'hours').format("YYYY-MM-DD")

show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> ($(".one_day.#{day} .#{event}").not(".hidden").length > 0) for event in events
has_no_event = (day) -> true not in event_array(day)

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

shaharit_is_fixed_at = (day, hour, minute, hebrewDate, gregorianDate) ->
  time = moment().hour(hour).minute(minute)
  vatikin = new Vatikin(gregorianDate, hebrewDate).schedule
  vatikin = vatikin.korbanot + vatikin.hodu + vatikin.yishtabach
  $(".#{day} .korbanot").html("#{time.format("h:mm")}<span class='screen-only'> and <br /><a href='shabbat.html'>#{vatikin} minutes<br />before sunrise</a></span>")
  $(".#{day} .hodu").html(time.add(15, 'minutes').format("h:mm"))
  $(".#{day} .yishtabach").html('')
  $(".#{day} .amidah").html('')

write_schedule = (day_iterator) ->
  $('.start-hidden').addClass('hidden')
  $('.start-shown').removeClass('hidden')
  $(".one_day .selihot").html('')
  $(".one_day .omer").html('')
  day_iterator.day('Saturday')
  hebrew_date = null
  for day in moment.weekdays().reverse()
    window.catching_errors 'Morning', day_iterator.toDate(), ->
      $(".#{day} .date").html(day_iterator.format("D MMM"))
      hebrew_date = new HebrewDate(day_iterator.toDate())
      $(".#{day} .hebrew_date").html("#{hebrew_date.staticHebrewMonth.name} #{hebrew_date.dayOfMonth}")
      show_event(day, event, hebrew_date) for event in events
      if hebrew_date.isYomKippur()
        shaharit_is_fixed_at(day, 7, 0, hebrew_date, day_iterator)
      else if hebrew_date.is1stDayOfShabuot()
        new Vatikin(day_iterator, hebrew_date).updateDOM()
      else if hebrew_date.is1stDayOfPesach() || hebrew_date.is2ndDayOfPesach()
        shaharit_is_fixed_at(day, 8, 45, hebrew_date, day_iterator)
      else if hebrew_date.isYomTov() || hebrew_date.isShabbat()
        shaharit_is_fixed_at(day, 7, 45, hebrew_date, day_iterator)
      else
        new Vatikin(day_iterator, hebrew_date).updateDOM()
    window.catching_errors 'Afternoon', day_iterator.toDate(), ->
      afternoon = mincha_and_arbit(day_iterator)
      $(".#{day} .mincha").html(afternoon.mincha || "")
      $(".#{day} .arbit").html(afternoon.arbit || "")
    $(".#{day} .omer").removeClass('hidden').html("#{day_iterator.format('ddd')}. night: <b>#{hebrew_date.omer().tonight}</b>") if hebrew_date.omer()? and hebrew_date.omer().tonight
    day_iterator.subtract(1, 'days')
  $(".header .event")[show_if($('.one_day .event').not('.hidden').length > 0)]('hidden')
  ($(".#{day} .placeholder")[show_if(has_no_event(day))]('hidden') for day in moment.weekdays()) unless $(".header .event").hasClass('hidden')
  for column in ['selihot', 'omer']
    $(".header .#{column}")[show_if($(".one_day .#{column}").not('.hidden').length > 0)]('hidden')
    ($(".#{day} .#{column}").removeClass('hidden') for day in moment.weekdays()) unless $(".header .#{column}").hasClass('hidden')

$ ->
  window.events = (e.className.replace(/start-hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.Saturday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(initialDate()).change()
  $(".Saturday.one_day td:nth-child(1)").html("שַׁבָּת")
