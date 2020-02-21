#= require ../site/zmanim
#= require ../site/hebrewDateExtensions
#= require ../site/helpers

minutesBefore = NaharShalomScheduleHelpers.minutesBefore
minutesAfter = NaharShalomScheduleHelpers.minutesAfter
roundedToNearest5Minutes = NaharShalomScheduleHelpers.roundedToNearest5Minutes

class Arbit
  constructor: (hebrewDate, plag, sunset, setHaKochabimGeonim, setHaKochabim3Stars) ->
    [@hebrewDate, @plag, @sunset, @setHaKochabimGeonim, @setHaKochabim3Stars] = [hebrewDate, plag, sunset, setHaKochabimGeonim, setHaKochabim3Stars]
  time: -> @_time ?= switch
    when @hebrewDate.isErebYomKippur() then roundedToNearest5Minutes(minutesBefore(@sunset, 55))
    when @hebrewDate.isYomKippur() then minutesAfter(@setHaKochabim3Stars, 10).seconds(0)
    when @hebrewDate.isErebShabbat() || (@hebrewDate.isErebYomTob() && !@hebrewDate.isShabbat()) then null
    when @hebrewDate.isShabbat() && !@hebrewDate.tonightIsYomTob()
      minutesAfterShabbatEnds = if moment(@hebrewDate.gregorianDate).isBefore(moment("2020-02-20", "YYYY-MM-DD")) && !@hebrewDate.isEreb9Ab() then 10 else 0
      minutesAfter(@setHaKochabim3Stars, minutesAfterShabbatEnds).seconds(0)
    when @hebrewDate.yomYobThatWePrayAtPlag() && !@hebrewDate.isShabbat() then moment(@plag).seconds(60)
    when @hebrewDate.hasHadlakatNerotAfterSetHaKochabim() then moment(@setHaKochabimGeonim).seconds(0)
    when @hebrewDate.is2ndDayOfYomTob() then roundedToNearest5Minutes(minutesBefore(@setHaKochabim3Stars, 10))
    else moment(@sunset).seconds(0)

(exports ? this).Arbit = Arbit
