//= require ./mincha
//= require ./arbit
//= require ../site/hebrewDateExtensions

class WeekTable
  constructor: (gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, events) ->
    [@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @events] = [gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, events]
  hasSelihot: -> @_hasSelihot ?= true in (shaharit.hasSelihot() for shaharit in @shaharitWeek)
  hasOmer: -> @_hasOmer ?= true in (hebrewDate.omer()? for hebrewDate in @hebrewWeek)
  hasEvents: ->
    @_hasEvents ?= true in for hebrewDate in @hebrewWeek
      true in (hebrewDate["is#{event}"]() for event, name of @events)
  dateOfNextHadlakatNerot: (i) ->
    i++ until @hebrewWeek[i].hasHadlakatNerot()
    i
  nextHadlakatNerot: (iterator) -> moment(@zmanimWeek[@dateOfNextHadlakatNerot(iterator)].sunset()).subtract(19.5, 'minutes')
  generateHeaderRow:  ->
    """
      <tr>
        <th></th>
        <th></th>
        <th></th>
        #{if @hasSelihot() then "<th>סְלְיחוֹת</th>" else ""}
        <th>קָרְבָּנוֹת</th>
        <th>הוֹדוּ</th>
        <th>יִשְׁתַּבַּח</th>
        <th>עֲמִידָה</th>
        <th>מִנְחָה</th>
        <th>עַרְבִית</th>
        #{if @hasOmer() then "<th>סְפִירַת הָעֹמֶר</th>" else ""}
        #{if @hasEvents() then "<th></th>" else ""}
      </tr>
    """
  hebrewMonthAndDate: (hebrewDate) -> "#{hebrewDate.staticHebrewMonth.name} #{hebrewDate.dayOfMonth}"
  dayOfWeek: (gregorianDate, hebrewDate) -> if hebrewDate.isShabbat() then "שַׁבָּת" else gregorianDate.format("dddd")
  selihot: (shaharit) -> if @hasSelihot() then "<td>#{if shaharit.selihot()? then shaharit.selihot().format("h:mm") else ""}</td>" else ""
  mincha: (hebrewDate, zmanim, iterator) -> (new Mincha(hebrewDate, zmanim.plag(), zmanim.sunset()).time() ? @nextHadlakatNerot(iterator)).format("h:mm")
  arbit: (hebrewDate, zmanim) ->
    arbit = new Arbit(hebrewDate, zmanim.plag(), zmanim.sunset().subtract(30, 'seconds'), zmanim.setHaKochabimGeonim(), zmanim.setHaKochabim3Stars()).time()
    if arbit? then arbit.format("h:mm") else ""
  omer: (gregorianDate, hebrewDate) ->
    if (hebrewDate.omer()? && hebrewDate.omer().tonight)
      "#{gregorianDate.format('ddd')}. night: <b>#{hebrewDate.omer().tonight}</b>"
    else
      ""
  eventList: (hebrewDate) ->
    list = []
    for event, name of @events
      list.push name if hebrewDate["is#{event}"]()
    list
  generateRow: (iterator) ->
    [gregorianDate, hebrewDate, zmanim, shaharit] = [@gregorianWeek[iterator], @hebrewWeek[iterator], @zmanimWeek[iterator], @shaharitWeek[iterator]]
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
    """
      <tr>
        <td>#{@dayOfWeek(gregorianDate, hebrewDate)}</td>
        <td>#{gregorianDate.format("D MMM")}</td>
        <td>#{@hebrewMonthAndDate(hebrewDate)}</td>
        #{@selihot(shaharit)}
        <td>#{korbanot}</td>
        <td>#{hodu}</td>
        <td>#{yishtabach}</td>
        <td class='bold'>#{amidah}</td>
        <td>#{@mincha(hebrewDate, zmanim, iterator)}</td>
        <td>#{@arbit(hebrewDate, zmanim)}</td>
        #{if @hasOmer() then "<td>#{@omer(gregorianDate, hebrewDate)}</td>" else ""}
        #{if @hasEvents() then "<td>#{@eventList(hebrewDate).join(" / ")}</td>" else ""}
      </tr>
    """

(exports ? this).WeekTable = WeekTable
