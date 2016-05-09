//= require ../site/raven
//= require ../site/shaharit
//= require ./writeSchedule

initialDate = ->
  initialDate = window.location.search.replace("?", "")
  initialDate = if initialDate.length > 0 then moment(initialDate, "YYYYMMDD").toDate() else (new Date())
  moment(initialDate).add(12, 'hours').format("YYYY-MM-DD")

show_event = (day, event, hebrew_date) -> $(".#{day} .#{event}")[show_if(hebrew_date["is#{event}"]())]('hidden')

event_array = (day) -> ($(".one_day.#{day} .#{event}").not(".hidden").length > 0) for event in events
has_no_event = (day) -> true not in event_array(day)

show_if = (condition) -> if condition then 'removeClass' else 'addClass'

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
      sunrise = new Sunrise(day_iterator).get()
      sofZmanKeriatShema = new Zmanim(day_iterator, window.config).sofZmanKeriatShema()
      shaharit = new Shaharit(hebrew_date, sunrise, sofZmanKeriatShema)
      if shaharit.selihot()?
        $(".#{day} .selihot").removeClass('hidden').html(shaharit.selihot().format("h:mm"))
      korbanot = (time.format("h:mm") for time in shaharit.korbanot())
      hodu = (time.format("h:mm") for time in shaharit.hodu())
      switch hodu.length
        when 2
          korbanot = "<span class='screen-only'><a href='shabbat.html'>#{korbanot[0]}</a> and </span>#{korbanot[1]}"
          hodu = "<span class='screen-only'><a href='shabbat.html'>#{hodu[0]}</a> and </span>#{hodu[1]}"
          yishtabach = ""
          amidah = "<span class='screen-only'><a href='shabbat.html'>#{shaharit.amidah().format("h:mm:ss")}</a>"
        when 1
          korbanot = korbanot[0]
          hodu = hodu[0]
          yishtabach = shaharit.yishtabach().format("h:mm")
          amidah = shaharit.amidah().format("h:mm:ss")
        else throw "This should never happen!"
      $(".#{day} .korbanot").html(korbanot)
      $(".#{day} .hodu").html(hodu)
      $(".#{day} .yishtabach").html(yishtabach)
      $(".#{day} .amidah").html(amidah)
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
  window.catching_errors 'Resizing Chag Tables', day_iterator.toDate(), ->
    visible_tables = $("#chagim-tables > div").not(".hidden").not(".announcement")
    has_announcement = $("#chagim-tables > div.announcement").not(".hidden").size() > 0
    visible_tables.removeClass("col-xs-5").removeClass("col-xs-6").removeClass("col-xs-7").removeClass("col-xs-8")
    new_width = switch visible_tables.size()
      when 1
        if has_announcement then [7] else [8]
      when 2
        switch
          when $("#chagim-tables > div.shabbat .zachor").not(".hidden").size() > 0 then [5,7]
          else [6,6]
      when 3
        switch
          when $("#chagim-tables > div.rosh-hashana").not(".hidden").size() > 0 then [6,6,6]
          else throw "This should never happen!"
    visible_tables.each (i) -> $(this).addClass("col-xs-#{new_width[i]}")

$ ->
  window.events = (e.className.replace(/start-hidden/, '').replace(/event/, '').replace(/\s*/, '') for e in $('.Saturday .event'))
  $('.calendar').change(-> write_schedule(moment(this.value))).val(initialDate()).change()
  $(".Saturday.one_day td:nth-child(1)").html("שַׁבָּת")
