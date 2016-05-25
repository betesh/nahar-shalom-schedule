//= require ../vendor/hebrewDate
//= require ../site/coordinates
//= require ../site/sunrise
//= require ../site/shaharit
//= require ./mincha
//= require ../site/zmanim
//= require ./hebrewEvents
//= require ./weekTable
//= require ./holidayTableFactory

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
  when hebrewDate.is7thDayOfPesach() || hebrewDate.is8thDayOfPesach() then " שְׁבִיעִי וְאַחֲרוֹן שֶׁל פֶּסַח"
  when hebrewDate.is1stDayOfPesach() || hebrewDate.is2ndDayOfPesach() then "יוֹם טוֹב רִאשׁוֹן שֶׁל פֶּסַח"
  when hebrewDate.isSukkot() && hebrewDate.isYomTob() && !hebrewDate.isSheminiAseret() then "חַג הַסֻּכּוֹת"
  when hebrewDate.isSheminiAseret() then "שְּׁמִינִי עֲצֶרֶת"
  when hebrewDate.isSheminiAseret() then "שִׂמְחַת תּוֹרָה"
  when hebrewDate.isShabbat() then "שַׁבָּת"

class TableFactory
  constructor: (gregorianDate) ->
    gregorianDate = gregorianDate
    @gregorianWeek = (moment(gregorianDate).day(weekday) for weekday in moment.weekdays())
    @hebrewWeek = (new HebrewDate(date.toDate()) for date in @gregorianWeek)
    @zmanimWeek = (new Zmanim(day, window.coordinates) for day in @gregorianWeek)
    @shaharitWeek = for i in [0...(@gregorianWeek.length)]
      new Shaharit(@hebrewWeek[i], new Sunrise(@gregorianWeek[i]).get(), @zmanimWeek[i].sofZmanKeriatShema())
    @minchaWeek = (@mincha(i) for i in [0...(@gregorianWeek.length)])
  dateOfNextHadlakatNerot: (i) ->
    i++ until @hebrewWeek[i].hasHadlakatNerot()
    i
  nextHadlakatNerot: (iterator) -> @zmanimWeek[@dateOfNextHadlakatNerot(iterator)].hadlakatNerot()
  mincha: (iterator) -> new Mincha(@hebrewWeek[iterator], @zmanimWeek[iterator].plag(), @zmanimWeek[iterator].sunset()).time() ? @nextHadlakatNerot(iterator)
  generateWeekTable: ->
    weekTable = new WeekTable(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek, window.HebrewEvents)
    weekTableRows = for i in [0...(@gregorianWeek.length)]
      weekTable.generateRow(i)
    weekTable.generateHeaderRow() + weekTableRows.join('')
  generateHolidayTables: ->
    holidayTableFactory = new HolidayTableFactory(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek)
    tableSections = []
    tableSectionTitles = []
    tables = []
    for i in [0...(@gregorianWeek.length)]
      hebrewDate = @hebrewWeek[i]
      tableSection = holidayTableFactory.generateTableSection(i)
      endOfTable = hebrewDate.isShabbat() || hebrewDate.is2ndDayOfYomTob() || hebrewDate.isPurim() || hebrewDate.is10Tevet()
      if tableSection?
        tableSections.push(tableSection)
        tableSectionTitle = title(hebrewDate)
        tableSectionTitles.push(tableSectionTitle) if tableSectionTitle? and (tableSectionTitle not in tableSectionTitles)
      if (endOfTable || !tableSection?) && tableSections.length > 0
        table = tableSections.join("")
        titles = tableSectionTitles.join(" / ")
        table = "<table class='table table-striped table-condensed'><tr><th colspan=4 class='text-center'>#{titles}</th></tr>#{table}</table>"
        tables.push(table)
        tableSections = []
        tableSectionTitles = []
    tables

(exports ? this).TableFactory = TableFactory
