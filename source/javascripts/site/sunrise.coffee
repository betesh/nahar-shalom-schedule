//= require ./sunrises
//= require ../vendor/hebrewDate

class Sunrise
  constructor: (momentInstance) ->
    dstOffset = if moment(momentInstance).hour(12).isDST() then 1 else 0
    hebrewDate = new HebrewDate(momentInstance.toDate())
    sunrisesThisYear = window.sunrises["#{hebrewDate.getYearFromCreation()}"]
    if sunrisesThisYear
      doy = hebrewDate.getDayOfYear()
      @sunrise = moment(sunrisesThisYear[doy - 1], 'h:mm:ss').add(dstOffset, 'hours').year(momentInstance.year()).month(momentInstance.month()).date(momentInstance.date())
  time: -> @sunrise

window.Sunrise = Sunrise
