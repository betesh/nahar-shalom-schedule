class Sunrise
  constructor: (moment_instance) ->
    dst = moment(moment_instance).hour(12).isDST()
    hebrew_date = new HebrewDate(moment_instance.toDate())
    this_year_sunrises = window.sunrises["#{hebrew_date.year}"]
    doy = hebrew_date.day_of_year()
    doy += this_year_sunrises.length if doy < 0
    @sunrise = moment(this_year_sunrises[doy], 'h:mm:ss').add('hours', if dst then 1 else  0).year(moment_instance.year()).month(moment_instance.month()).date(moment_instance.date())
  get: -> @sunrise

window.Sunrise = Sunrise