//= require ../site/zmanim
//= require ../site/hebrewDateExtensions
//= require ../site/helpers

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
    when @hebrewDate.isShabbat() && @hebrewDate.isEreb9Ab() then minutesAfter(@setHaKochabim3Stars, 0).seconds(0)
    when @hebrewDate.isShabbat() && !@hebrewDate.tonightIsYomTob() then minutesAfter(@setHaKochabim3Stars, 10).seconds(0)
    when @hebrewDate.yomYobThatWePrayAtPlag() && !@hebrewDate.isErebShabbat() && !@hebrewDate.isShabbat() then moment(@plag).seconds(60)
    when @hebrewDate.hasHadlakatNerotAfterSetHaKochabim() then moment(@setHaKochabimGeonim).seconds(0)
    when @hebrewDate.is2ndDayOfYomTob() && !@hebrewDate.isErebShabbat() then roundedToNearest5Minutes(minutesBefore(@setHaKochabim3Stars, 10))
    else moment(@sunset).seconds(0)

(exports ? this).Arbit = Arbit
