//= require ./weekTableFactory
//= require ../site/raven
//= require ../site/shaharit
//= require ./holidaySchedule
//= require ./shabbatEvents
//= require ./announcement

initialDate = ->
  initialDate = window.location.search.replace("?", "")
  initialDate = if initialDate.length > 0 then moment(initialDate, "YYYYMMDD").toDate() else (new Date())
  moment(initialDate).add(12, 'hours').format("YYYY-MM-DD")

write_schedule = (day_iterator) ->
  $('.start-hidden').addClass('hidden')
  $('.start-shown').removeClass('hidden')
  weekTableFactory = new WeekTableFactory(day_iterator)
  window.catching_errors 'Morning', day_iterator.toDate(), ->
    $(".weekly-table").html(weekTableFactory.generateTable())
  window.catching_errors 'Sedra', day_iterator.toDate(), ->
    for hebrewDate in weekTableFactory.hebrewWeek
      if hebrewDate.isShabbat()
        sedra = "#{if hebrewDate.isRegel() || hebrewDate.isYomKippur() || hebrewDate.isYomTob() then "" else "שַׁבַּת פְּרָשָׁת"} #{hebrewDate.sedra().replace(/-/g, ' - ')}"
        for event, name of window.ShabbatEvents
          sedra = "#{sedra} &mdash; #{name}" if hebrewDate["is#{event}"]()
        $('.sedra').html(sedra)
  window.catching_errors 'Holiday Schedule', day_iterator.toDate(), ->
    for i in [0...(weekTableFactory.gregorianWeek.length)]
      gregorianDate = weekTableFactory.gregorianWeek[i]
      hebrewDate = weekTableFactory.hebrewWeek[i]
      zmanim = weekTableFactory.zmanimWeek[i]
      schedule = new HolidaySchedule(gregorianDate, hebrewDate, zmanim)
      if hebrewDate.hasHadlakatNerot()
        schedule.hadlakat_nerot_schedule()
      if hebrewDate.isYomKippur()
        schedule.yom_kippur_schedule()
      else if hebrewDate.isShabbat() || hebrewDate.isYomTob()
        schedule.shabbat_schedule()
      else if hebrewDate.isTaanit() || hebrewDate.isEreb9Ab() || hebrewDate.isPurim()
        schedule.taanit_schedule()
      if hebrewDate.isErebHoshanaRaba()
        schedule.tiqun_leil_hoshana_raba_schedule()
  window.catching_errors 'Announcements', day_iterator.toDate(), ->
    for i in [0...(weekTableFactory.gregorianWeek.length)]
      hebrewDate = weekTableFactory.hebrewWeek[i]
      if hebrewDate.isShabbat() || hebrewDate.isErebPesach()
        zmanim = weekTableFactory.zmanimWeek[i]
        announcement = new Announcement(hebrewDate, zmanim).announcement()
        $(".announcement.jumbotron").removeClass('hidden').html(announcement) if announcement?
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
  $('.calendar').change(-> write_schedule(moment(this.value))).val(initialDate()).change()
