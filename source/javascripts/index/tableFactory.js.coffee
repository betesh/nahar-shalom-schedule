#= require ../vendor/hebrewDate
#= require ../site/coordinates
#= require ../site/sunrise
#= require ../site/shaharit
#= require ./mincha
#= require ../site/zmanim
#= require ./hebrewEvents
#= require ./weekTable
#= require ./holidayTableFactory

endOfTable = (hebrewDate) ->
  hebrewDate.isShabbat() ||
  hebrewDate.is2ndDayOfYomTob() ||
  hebrewDate.isPurim() ||
  hebrewDate.isYomKippur() ||
  (hebrewDate.isTaanit() && !hebrewDate.isErebPurim())

title = (hebrewDate) -> switch
  when hebrewDate.is9Ab() then "תִּשְׁעָה בְּאָב"
  when hebrewDate.isRoshHashana() then "רֹאשׁ הַשָּׁנָה"
  when hebrewDate.isYomKippur() then "יוֹם הַכִּפֻּרִים"
  when hebrewDate.isShabuot() then "חַג הַשָׁבֻעֹת"
  when hebrewDate.is17Tamuz() then "שִׁבְעָה עֲשָׂר בְּתַּמוּז"
  when hebrewDate.is10Tevet() then "עֲשָׂרָה בְּטֵבֵת"
  when hebrewDate.isTaanitEster() then "תַּעֲנִית אֶסְתֵּר"
  when hebrewDate.isFastOfGedaliah() then "צוֹם גְּדַלְיָה"
  when hebrewDate.isPurim() then "פּוּרִים"
  when hebrewDate.is7thDayOfPesach() || hebrewDate.is8thDayOfPesach() then "שְׁבִיעִי וְאַחֲרוֹן שֶׁל פֶּסַח"
  when hebrewDate.is1stDayOfPesach() || hebrewDate.is2ndDayOfPesach() then "יוֹם טוֹב רִאשׁוֹן שֶׁל פֶּסַח"
  when hebrewDate.isSukkot() && hebrewDate.isYomTob() && !hebrewDate.isSheminiAseret() then "חַג הַסֻּכּוֹת"
  when hebrewDate.isErebHoshanaRaba() then "#{if hebrewDate.isShabbat() then "שַׁבָּת / לֵיל " else ""}הוֹשַׁעֲנָא רַבָּא"
  when hebrewDate.isSheminiAseret() && hebrewDate.is1stDayOfYomTob() then "שְּׁמִינִי עֲצֶרֶת"
  when hebrewDate.isSheminiAseret() && hebrewDate.is2ndDayOfYomTob() then "שִׂמְחַת תּוֹרָה"
  when hebrewDate.isShabbat() then "שַׁבָּת"

class TableFactory
  constructor: (gregorianDate) ->
    gregorianDate = gregorianDate
    @gregorianWeek = (moment(gregorianDate).day(weekday) for weekday in moment.weekdays())
    @hebrewWeek = (new HebrewDate(date.toDate()) for date in @gregorianWeek)
    @zmanimWeek = (new Zmanim(day, window.coordinates) for day in @gregorianWeek)
    @shaharitWeek = (@shaharit(i) for i in [0...(@gregorianWeek.length)])
    @minchaWeek = (@mincha(i) for i in [0...(@gregorianWeek.length)])
  dateOfNextHadlakatNerot: (i) ->
    i++ until @hebrewWeek[i].hasHadlakatNerot()
    i
  nextHadlakatNerot: (iterator) -> @zmanimWeek[@dateOfNextHadlakatNerot(iterator)].hadlakatNerot()
  mincha: (iterator) -> new Mincha(@hebrewWeek[iterator], @zmanimWeek[iterator].plag(), @zmanimWeek[iterator].sunset()).time() ? @nextHadlakatNerot(iterator)
  sunrise: (iterator) -> new Sunrise(@gregorianWeek[iterator]).time() ? @zmanimWeek[iterator].sunrise()
  shaharit: (iterator) -> new Shaharit(@hebrewWeek[iterator], @sunrise(iterator), @zmanimWeek[iterator].sofZmanKeriatShema())
  generateWeekTable: ->
    weekTable = new WeekTable(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek, window.HebrewEvents)
    weekTableRows = (weekTable.generateRow(i) for i in [0...(@gregorianWeek.length)])
    sunrisesMissing = ((new Sunrise(@gregorianWeek[i]).time())? for i in [0...(@gregorianWeek.length)]).indexOf(false) != -1
    warningAboutMissingSunrises = if sunrisesMissing then "<thead><tr><th colspan='100%'  style='text-align:center'>WARNING: Sunrise times are based on degrees at location, not chaitables.com.  Fore more precise times for Vatikin, please contact a developer to download data from chaitables.com</th></tr></thead>" else ""
    "#{warningAboutMissingSunrises}<thead>#{weekTable.generateHeaderRow()}</thead><tbody>#{weekTableRows.join('')}</tbody>"
  generateHolidayTables: ->
    holidayTableFactory = new HolidayTableFactory(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek)
    tableSections = []
    tableSectionTitles = []
    tables = []
    for i in [0...(@gregorianWeek.length)]
      hebrewDate = @hebrewWeek[i]
      tableSection = holidayTableFactory.generateTableSection(i)
      if tableSection?
        tableSections.push(tableSection)
        tableSectionTitle = title(hebrewDate)
        tableSectionTitles.push(tableSectionTitle) if tableSectionTitle? and (tableSectionTitle not in tableSectionTitles)
      if (endOfTable(hebrewDate) || !tableSection?) && tableSections.length > 0
        table = """
          <table class='table table-striped table-sm'>
            <thead>
              <tr>
                <th colspan=4 class='text-center'>
                  #{tableSectionTitles.join(" / ")}
                </th>
              </tr>
            </thead>
            <tbody>#{tableSections.join("")}</tbody>
          </table>
        """
        tables.push(table)
        tableSections = []
        tableSectionTitles = []
    tables

(exports ? this).TableFactory = TableFactory
