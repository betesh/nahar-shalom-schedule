//= require ./tableFactory
//= require ../site/raven
//= require ../site/shaharit
//= require ./shabbatEvents
//= require ./announcement

initialDate = ->
  initialDate = window.location.search.replace("?", "")
  initialDate = if initialDate.length > 0 then moment(initialDate, "YYYYMMDD").toDate() else (new Date())
  moment(initialDate).add(12, 'hours').format("YYYY-MM-DD")

write_schedule = (day_iterator) ->
  $('.start-hidden').addClass('hidden')
  $('.start-shown').removeClass('hidden')
  tableFactory = new TableFactory(day_iterator)
  window.catching_errors 'Morning', day_iterator.toDate(), ->
    $(".weekly-table").html(tableFactory.generateWeekTable())
  window.catching_errors 'Sedra', day_iterator.toDate(), ->
    for hebrewDate in tableFactory.hebrewWeek
      if hebrewDate.isShabbat()
        sedra = "#{if hebrewDate.isRegel() || hebrewDate.isYomKippur() || hebrewDate.isYomTob() then "" else "שַׁבַּת פְּרָשָׁת"} #{hebrewDate.sedra().replace(/-/g, ' - ')}"
        for event, name of window.ShabbatEvents
          sedra = "#{sedra} &mdash; #{name}" if hebrewDate["is#{event}"]()
        $('.sedra').html(sedra)
  announcementHtml = ""
  window.catching_errors 'Announcements', day_iterator.toDate(), ->
    for i in [0...(tableFactory.gregorianWeek.length)]
      hebrewDate = tableFactory.hebrewWeek[i]
      if hebrewDate.isShabbat() || hebrewDate.isErebPesach()
        zmanim = tableFactory.zmanimWeek[i]
        announcement = new Announcement(hebrewDate, zmanim).announcement()
        announcementHtml = "<div class='col-lg-4 col-lg-offset-1 col-xs-5 jumbotron font22'>#{announcement}</div>" if announcement?
  window.catching_errors 'Holiday Schedule', day_iterator.toDate(), ->
    tables = tableFactory.generateHolidayTables()
    hasAnnouncement = "" != announcementHtml
    widths = switch tables.length
      when 1
        if hasAnnouncement then [7] else [8]
      when 2
        switch
          when tableFactory.hebrewWeek[6].isShabbatZachor() then [5,7]
          else [6,6]
      when 3
        switch
          when (true in (date.isRoshHashana() for date in tableFactory.hebrewWeek)) then [6,6,6]
          else throw "This should never happen!"
    html = ""
    for i in [0...(tables.length)]
      html = "#{html}<div class='col-xs-#{widths[i]}'>#{tables[i]}</div>"
    $('.chagim-tables').html(html + announcementHtml)

$ ->
  $('.calendar').change(-> write_schedule(moment(this.value))).val(initialDate()).change()
