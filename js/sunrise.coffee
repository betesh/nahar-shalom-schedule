class Sunrise
  constructor: (moment_instance) ->
    dst_offset = if moment(moment_instance).hour(12).isDST() then 1 else 0
    hebrew_date = new HebrewDate(moment_instance.toDate())
    this_year_sunrises = window.sunrises["#{hebrew_date.getYearFromCreation()}"]
    doy = hebrew_date.getDayOfYear()
    @sunrise = moment(this_year_sunrises[doy - 1], 'h:mm:ss').add(dst_offset, 'hours').year(moment_instance.year()).month(moment_instance.month()).date(moment_instance.date())
  get: -> @sunrise

window.Sunrise = Sunrise
