#= require ./arbit
#= require ../site/hebrewDateExtensions

linkToShabbatOnScreen = (content) -> "<span class='screen-only'><a href='shabbat.html'>#{content}</a></span><span class='print-only'>#{content}</span>"

class WeekTable
  constructor: (gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, minchaWeek, events) ->
    [@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek, @events] = [gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, minchaWeek, events]
  hasSelihot: -> @_hasSelihot ?= true in (shaharit.hasSelihot() for shaharit in @shaharitWeek)
  hasOmer: -> @_hasOmer ?= true in (hebrewDate.omer()? for hebrewDate in @hebrewWeek)
  hasEvents: ->
    @_hasEvents ?= true in for hebrewDate in @hebrewWeek
      true in (hebrewDate["is#{event}"]() for event, name of @events)
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
  arbit: (hebrewDate, zmanim) ->
    arbit = new Arbit(hebrewDate, zmanim.plag(), zmanim.sunset().subtract(30, 'seconds'), zmanim.setHaKochabimGeonim(), zmanim.setHaKochabim3Stars()).time()
    if arbit? then arbit.format("h:mm") else ""
  omer: (gregorianDate, hebrewDate, zmanim) ->
    if (hebrewDate.omer()? && hebrewDate.omer().tonight)
      "#{gregorianDate.format('ddd')}. night: <b>#{hebrewDate.omer().tonight}</b> (After #{zmanim.setHaKochabimGeonim().format('h:mm')})"
    else
      ""
  eventList: (hebrewDate) ->
    list = []
    for event, name of @events
      list.push name if hebrewDate["is#{event}"]()
    list
  generateRow: (iterator) ->
    [gregorianDate, hebrewDate, zmanim, shaharit, mincha] = [@gregorianWeek[iterator], @hebrewWeek[iterator], @zmanimWeek[iterator], @shaharitWeek[iterator], @minchaWeek[iterator]]
    korbanot = (time.format("h:mm") for time in shaharit.korbanot())
    hodu = (time.format("h:mm") for time in shaharit.hodu())
    switch hodu.length
      when 2
        korbanot = "#{linkToShabbatOnScreen(korbanot[0])} and #{korbanot[1]}"
        hodu = "#{linkToShabbatOnScreen(hodu[0])} and #{hodu[1]}"
        yishtabach = ""
        amidah = "#{linkToShabbatOnScreen(shaharit.amidah().format("h:mm:ss"))}"
      when 1
        korbanot = korbanot[0]
        hodu = hodu[0]
        yishtabach = shaharit.yishtabach().format("h:mm")
        amidah = shaharit.amidah().format("h:mm:ss")
      else throw "This should never happen!"
    kinnusDate = gregorianDate.isSame('2015-09-01', 'day') || gregorianDate.isSame('2016-06-05', 'day')
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
        <td>#{if kinnusDate then "" else mincha.format("h:mm")}</td>
        <td>#{if kinnusDate then "" else @arbit(hebrewDate, zmanim)}</td>
        #{if @hasOmer() then "<td>#{@omer(gregorianDate, hebrewDate, zmanim)}</td>" else ""}
        #{if @hasEvents() then "<td>#{@eventList(hebrewDate).join(" / ")}</td>" else ""}
      </tr>
    """

(exports ? this).WeekTable = WeekTable
