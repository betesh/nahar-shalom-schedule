//= require index/arbit
//= require qunit/helpers

occasionsThatDoNotAffectArbit = ["HataratNedarim", "10DaysOfTeshuba", "ErubTabshilin", "Regel", "ShabbatHaGadol", "Moed", "MaharHodesh", "ShabbatMevarechim"]
assertTimeEqual = QunitHelpers.assertTimeEqual

arbitTest = (gregorianDate, hours, minutes, sunsetHour = 19) ->
  hebrewDate = new HebrewDate(gregorianDate)
  plag = moment(gregorianDate).hour(sunsetHour - 1).minute(17).seconds(16)
  sunset = moment(gregorianDate).hour(sunsetHour).minute(21).seconds(23)
  setHaKochabimGeonim = moment(gregorianDate).hour(sunsetHour).minute(45).seconds(46)
  setHaKochabim3Stars = moment(gregorianDate).hour(sunsetHour + 1).minute(37).seconds(38)
  events = hebrewDate.occasions().filter((e) -> (-1 == occasionsThatDoNotAffectArbit.indexOf(e))).join(" / ")
  QUnit.test "When plag is at #{plag.format("hh:mm:ss A")}, sunset is at #{sunset.format("hh:mm:ss A")}, setHaKochabimGeonim is at #{setHaKochabimGeonim.format("hh:mm:ss A")} and setHaKochabim3Stars is at #{setHaKochabim3Stars.format("hh:mm:ss A")}  on #{events}", (assert) ->
    arbit = new Arbit(hebrewDate, plag, sunset, setHaKochabimGeonim, setHaKochabim3Stars)
    assertTimeEqual assert, arbit.time(), moment(gregorianDate).hour(hours).minute(minutes).second(0), "Arbit"

nullArbitTest = (gregorianDate) ->
  hebrewDate = new HebrewDate(gregorianDate)
  events = hebrewDate.occasions().filter((e) -> (-1 == occasionsThatDoNotAffectArbit.indexOf(e))).join(" / ")
  events = "a regular weekday" if "" == events
  QUnit.test "On #{events}", (assert) ->
    arbit = new Arbit(hebrewDate, null, null, null, null)
    assert.equal arbit.time(), null, "Arbit class does not return a time"

$ ->
  # Weekday
  arbitTest(new Date(2016,4,5), 19, 21)

  # Ereb Shabbat
  nullArbitTest(new Date(2016,4,6))

  # Shabbat
  arbitTest(new Date(2016,4,7), 20, 47)

  # Ereb Pesach
  nullArbitTest(new Date(2017,3,10))

  # Ereb Pesach on Shabbat
  arbitTest(new Date(2021,2,27), 19, 45)

  # Ereb Pesach on Ereb Shabbat
  nullArbitTest(new Date(2016,3,22))

  # 6th Day of Pesach
  nullArbitTest(new Date(2017,3,16))

  # 6th Day of Pesach on Ereb Shabbat
  nullArbitTest(new Date(2021,3,2))

  # 7th Day of Pesach
  arbitTest(new Date(2017,3,17), 18, 18)

  # 7th Day of Pesach on Shabbat
  arbitTest(new Date(2021,3,3), 19, 45)

  # 7th Day of Pesach on Ereb Shabbat
  nullArbitTest(new Date(2016,3,29))

  # 8th Day of Pesach
  arbitTest(new Date(2017,3,18), 20, 25)

  # 8th Day of Pesach on Shabbat
  arbitTest(new Date(2016,3,30), 20, 47)

  # Ereb Shabuot
  nullArbitTest(new Date(2021,4,16))

  # Ereb Shabuot on Shabbat
  arbitTest(new Date(2016,5,11), 19, 45)

  # 1st Day of Shabuot
  arbitTest(new Date(2021,4,17), 18, 18)

  # 1st Day of Shabuot on Ereb Shabbat
  nullArbitTest(new Date(2020,4,29))

  # 2nd Day of Shabuot
  arbitTest(new Date(2021,4,18), 20, 25)

  # 2nd Day of Shabuot on Shabbat
  arbitTest(new Date(2020,4,30), 20, 47)

  # Ereb 9 Ab
  arbitTest(new Date(2017,6,31), 19, 21)

  # Ereb 9 Ab on Shabbat
  arbitTest(new Date(2016,7,13), 20, 37)

  # Ereb Rosh Hashana
  nullArbitTest(new Date(2016,9,2))

  # Ereb Rosh Hashana on Ereb Shabbat
  nullArbitTest(new Date(2020,8,18))

  # 1st Day of Rosh Hashana
  arbitTest(new Date(2016,9,3), 19, 45)

  # 1st Day of Rosh Hashana on Shabbat
  arbitTest(new Date(2020,8,19), 19, 45)

  # 2nd Day of Rosh Hashana
  arbitTest(new Date(2016,9,4), 20, 25)

  # 2nd Day of Rosh Hashana on Ereb Shabbat
  nullArbitTest(new Date(2014,8,26))

  # Ereb Yom Kippur
  arbitTest(new Date(2016,9,11), 18, 25)

  # Ereb Yom Kippur on Ereb Shabbat
  arbitTest(new Date(2017,8,29), 18, 25)

  # Yom Kippur
  arbitTest(new Date(2016,9,12), 20, 47)

  # Yom Kippur on Shabbat
  arbitTest(new Date(2017,8,30), 20, 47)

  # Ereb Sukkot
  nullArbitTest(new Date(2017,9,4))

  # Ereb Sukkot on Ereb Shabbat
  nullArbitTest(new Date(2020,9,2))

  # 1st Day of Sukkot
  arbitTest(new Date(2017,9,5), 19, 45)

  # 1st Day of Sukkot on Shabbat
  arbitTest(new Date(2020,9,3), 19, 45)

  # 2nd Day of Sukkot
  arbitTest(new Date(2016,9,18), 20, 25)

  # 2nd Day of Sukkot on Ereb Shabbat
  nullArbitTest(new Date(2014,9,10))
