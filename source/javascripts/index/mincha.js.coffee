#= require ../site/hebrewDateExtensions
#= require ../site/helpers

minutesBefore = NaharShalomScheduleHelpers.minutesBefore
roundedToNearest5Minutes = NaharShalomScheduleHelpers.roundedToNearest5Minutes

class Mincha
  constructor: (hebrewDate, plag, sunset) ->
    [@hebrewDate, @plag, @sunset] = [hebrewDate, plag, sunset]
  threeThirty: -> moment(@sunset).hour(15).minute(30).seconds(0)
  sixThirty: -> moment(@sunset).hour(18).minute(30).seconds(0)
  onErebShabbat: -> moment.min(minutesBefore(@sunset, 33).seconds(0), @sixThirty())
  minutesBeforeSunset: -> @_minutesBeforeSunset ?= switch
    when @hebrewDate.isErebRoshHashana() then (if @hebrewDate.isErebShabbat() then 55 else 45)
    when @hebrewDate.isRoshHashana() then (if @hebrewDate.is1stDayOfYomTob() || @hebrewDate.isErebShabbat() then 60 else 40)
    when @hebrewDate.isYomKippur() then 195
    when @hebrewDate.is9Ab() then 45
    when @hebrewDate.isTaanitEster() then 35
    when @hebrewDate.isTaanit() then (if @hebrewDate.isErebShabbat() then 45 else 30)
    when @hebrewDate.isEreb9Ab() then (if @hebrewDate.isShabbat() then 100 else 55)
    when @hebrewDate.isErebShabuot() && @hebrewDate.isShabbat() then 80
    when @hebrewDate.tonightIsYomTob() && @hebrewDate.isShabbat() then 23
    when @hebrewDate.isErebPesach() then (if @hebrewDate.isErebShabbat() then 47 else 30)
    when @hebrewDate.isShabbat() then 45
    when @hebrewDate.isYomTob() && !@hebrewDate.yomYobThatWePrayAtPlag() then (if @hebrewDate.isErebShabbat() then 40 else 25)
    when @hebrewDate.isErebYomTob() then (if @hebrewDate.isErebShabbat() then 33 else  25)
    else null
  time: -> @_time ?= switch
    when @hebrewDate.isErebYomKippur() then @threeThirty()
    when @hebrewDate.is6thDayOfPesach() then @sixThirty()
    when @minutesBeforeSunset()? then roundedToNearest5Minutes(minutesBefore(@sunset, @minutesBeforeSunset()))
    when @hebrewDate.yomYobThatWePrayAtPlag() && !@hebrewDate.isErebShabbat() then roundedToNearest5Minutes(minutesBefore(@plag, 30))
    when @hebrewDate.isErebShabbat() then @onErebShabbat()
    else null

(exports ? this).Mincha = Mincha
