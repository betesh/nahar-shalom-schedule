#= require ./sunrises
#= require ../vendor/hebrewDate

class Sunrise
  constructor: (momentInstance) ->
    hebrewDate = new HebrewDate(momentInstance.toDate())
    dstOffset = if hebrewDate.getYearFromCreation() >= 5784 || !moment(momentInstance).hour(12).isDST() then 0 else 1
    sunrisesThisYear = window.sunrises["#{hebrewDate.getYearFromCreation()}"]
    if sunrisesThisYear
      doy = hebrewDate.getDayOfYear()
      @sunrise = moment(sunrisesThisYear[doy - 1], 'h:mm:ss').add(dstOffset, 'hours').year(momentInstance.year()).month(momentInstance.month()).date(momentInstance.date())
  time: -> @sunrise

window.Sunrise = Sunrise
