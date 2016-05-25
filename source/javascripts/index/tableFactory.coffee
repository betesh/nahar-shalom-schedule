//= require ../vendor/hebrewDate
//= require ../site/config
//= require ../site/sunrise
//= require ../site/shaharit
//= require ./mincha
//= require ../site/zmanim
//= require ./hebrewEvents
//= require ./weekTable

class TableFactory
  constructor: (gregorianDate) ->
    gregorianDate = gregorianDate
    @gregorianWeek = (moment(gregorianDate).day(weekday) for weekday in moment.weekdays())
    @hebrewWeek = (new HebrewDate(date.toDate()) for date in @gregorianWeek)
    @zmanimWeek = (new Zmanim(day, window.config) for day in @gregorianWeek)
    @shaharitWeek = for i in [0...(@gregorianWeek.length)]
      new Shaharit(@hebrewWeek[i], new Sunrise(@gregorianWeek[i]).get(), @zmanimWeek[i].sofZmanKeriatShema())
    @minchaWeek = (@mincha(i) for i in [0...(@gregorianWeek.length)])
  dateOfNextHadlakatNerot: (i) ->
    i++ until @hebrewWeek[i].hasHadlakatNerot()
    i
  nextHadlakatNerot: (iterator) -> moment(@zmanimWeek[@dateOfNextHadlakatNerot(iterator)].sunset()).subtract(19.5, 'minutes')
  mincha: (iterator) -> new Mincha(@hebrewWeek[iterator], @zmanimWeek[iterator].plag(), @zmanimWeek[iterator].sunset()).time() ? @nextHadlakatNerot(iterator)
  generateWeekTable: ->
    weekTable = new WeekTable(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek, window.HebrewEvents)
    weekTableRows = for i in [0...(@gregorianWeek.length)]
      weekTable.generateRow(i)
    weekTable.generateHeaderRow() + weekTableRows.join('')

(exports ? this).TableFactory = TableFactory
