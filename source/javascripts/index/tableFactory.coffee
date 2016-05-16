//= require ../vendor/hebrewDate
//= require ../site/config
//= require ../site/shaharit
//= require ../site/sunrise
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
  generateWeekTable: ->
    weekTable = new WeekTable(@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, window.HebrewEvents)
    weekTableRows = for i in [0...(@gregorianWeek.length)]
      weekTable.generateRow(i)
    weekTable.generateHeaderRow() + weekTableRows.join('')

(exports ? this).TableFactory = TableFactory
