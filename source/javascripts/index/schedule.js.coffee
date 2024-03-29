#= require ./tableFactory
#= require ../site/raven
#= require ../site/shaharit
#= require ./shabbatEvents
#= require ./announcement

initialDate = ->
  dateFromUrl = window.location.search.replace("?", "")
  if dateFromUrl.match(/^\d{8}$/)
    result = moment(dateFromUrl, "YYYYMMDD")
    result = null unless result.isValid()
  result ?= moment()
  result.add(12, 'hours').format("YYYY-MM-DD")

weekDescription = (shabbat) ->
  sedra = "#{if shabbat.isRegel() || shabbat.isYomKippur() || shabbat.isYomTob() then "" else "שַׁבַּת פְּרָשָׁת"} #{shabbat.sedra().replace(/-/g, ' - ')}"
  for event, name of window.ShabbatEvents
    sedra = "#{sedra} &mdash; #{name}" if shabbat["is#{event}"]()
  sedra

class Schedule
  constructor: (momentInstance) -> @momentInstance = momentInstance
  tableFactory: -> @_tableFactory ?= new TableFactory(@momentInstance)
  shabbat: -> @_shabbat ?= @tableFactory().hebrewWeek[6]
  iterators: -> @_iterators ?= [0...(@tableFactory().gregorianWeek.length)]
  catchingErrors: (description, fn) -> window.catchingErrors description, @momentInstance.toDate(), fn
  announcementHtml: -> @_announcementHtml ?= (=>
    for i in @iterators()
      hebrewDate = @tableFactory().hebrewWeek[i]
      if hebrewDate.isShabbat() || hebrewDate.isErebPesach()
        # TODO: If Shabbat during the week of Ereb Pesach has an announcement, the Shabbat one will be ignored
        zmanim = @tableFactory().zmanimWeek[i]
        announcement = new Announcement(hebrewDate, zmanim).announcement()
        switch announcement.length
          when 1
            return "<div class='col-lg-4 offset-lg-1 col-5 jumbotron font22'>#{announcement}</div>"
          when 2
            return "<div class='col-lg-4 offset-lg-1 col-5 jumbotron font22 double-jumbotron'>#{announcement.join("<br><br>")}</div>"
    false
  )()
  holidayTableWidths: (length) -> @_holidayTableWidths ?= switch length
    when 1
      if @announcementHtml()? then [7] else [8]
    when 2
      switch
        when @shabbat().isShabbatZachor() then [5,7]
        else [6,6]
    when 3
      switch
        when (true in (date.isRoshHashana() for date in @tableFactory().hebrewWeek)) then [6,6,6]
        else throw "This should never happen!"
  writeWeekTable: -> @catchingErrors 'Week Table', => $(".weekly-table").html(@tableFactory().generateWeekTable())
  writeSedra: -> @catchingErrors 'Sedra', => $('.sedra').html(weekDescription(@shabbat()))
  writeHolidaySchedule: -> @catchingErrors 'Holiday Schedule', =>
    tables = @tableFactory().generateHolidayTables()
    widths = @holidayTableWidths(tables.length)
    html = for i in [0...(tables.length)]
      "<div class='col-#{widths[i]}'>#{tables[i]}</div>"
    $('.chagim-tables').html(html.join('') + (@announcementHtml() || ''))
  writeSchedule: ->
    if @momentInstance.isValid()
      @writeWeekTable()
      @writeSedra()
      @writeHolidaySchedule()
    else
      @catchingErrors 'Invalid Date', =>
        html = """
          <table class='table table-striped table-sm'>
            <thead>
              <tr>
                <th colspan=4 class='text-center'>
                  Please enter a valid date!
                </th>
              </tr>
            </thead>
          </table>
        """
        $(".weekly-table").html(html)
        $(".sedra").html('')
        $(".chagim-tables").html('')

$ ->
  $('.calendar').change(-> (new Schedule(moment(this.value))).writeSchedule()).val(initialDate()).change()
