#= require index/mincha
#= require qunit/helpers

occasionsThatDoNotAffectMincha = ["HataratNedarim", "10DaysOfTeshuba", "ErubTabshilin", "Regel", "ShabbatHaGadol", "Moed", "MaharHodesh", "ShabbatMevarechim"]
assertTimeEqual = QunitHelpers.assertTimeEqual

minchaTest = (gregorianDate, hours, minutes, sunsetHour = 19) ->
  hebrewDate = new HebrewDate(gregorianDate)
  plag = moment(gregorianDate).hour(sunsetHour - 1).minute(17).seconds(16)
  sunset = moment(gregorianDate).hour(sunsetHour).minute(21).seconds(23)
  events = hebrewDate.occasions().filter((e) -> (-1 == occasionsThatDoNotAffectMincha.indexOf(e))).join(" / ")
  QUnit.test "When plag is at #{plag.format("hh:mm:ss A")} and sunset is at #{sunset.format("hh:mm:ss A")} on #{events}", (assert) ->
    mincha = new Mincha(hebrewDate, plag, sunset)
    assertTimeEqual assert, mincha.time(), moment(gregorianDate).hour(hours).minute(minutes).second(0), "Mincha"

nullMinchaTest = (gregorianDate) ->
  hebrewDate = new HebrewDate(gregorianDate)
  events = hebrewDate.occasions().filter((e) -> (-1 == occasionsThatDoNotAffectArbit.indexOf(e))).join(" / ")
  events = "a regular weekday" if "" == events
  QUnit.test "On #{events}", (assert) ->
    mincha = new Mincha(hebrewDate, null, null)
    assert.equal mincha.time(), null, "Mincha class does not return a time"

$ ->
  # Weekday
  nullMinchaTest(new Date(2016,4,5))

  # Ereb Shabbat (summer)
  minchaTest(new Date(2016,4,6), 18, 30)

  # Ereb Shabbat (winter)
  minchaTest(new Date(2016,4,6), 16, 48, 17)

  # Shabbat
  minchaTest(new Date(2016,4,7), 18, 35)

  # Ereb Pesach
  minchaTest(new Date(2017,3,10), 18, 50)

  # Ereb Pesach on Shabbat
  minchaTest(new Date(2021,2,27), 18, 55)

  # Ereb Pesach on Ereb Shabbat
  minchaTest(new Date(2016,3,22), 18, 30)

  # 6th Day of Pesach
  minchaTest(new Date(2017,3,16), 18, 30)

  # 6th Day of Pesach on Ereb Shabbat
  minchaTest(new Date(2021,3,2), 18, 30)

  # 7th Day of Pesach
  minchaTest(new Date(2017,3,17), 17, 45)

  # 7th Day of Pesach on Shabbat
  minchaTest(new Date(2021,3,3), 18, 55)

  # 7th Day of Pesach on Ereb Shabbat
  minchaTest(new Date(2016,3,29), 18, 30)

  # 8th Day of Pesach
  minchaTest(new Date(2017,3,18), 18, 55)

  # 8th Day of Pesach on Shabbat
  minchaTest(new Date(2016,3,30), 18, 35)

  # Ereb Shabuot
  minchaTest(new Date(2021,4,16), 18, 55)

  # Ereb Shabuot on Shabbat
  minchaTest(new Date(2016,5,11), 18, 0)

  # 1st Day of Shabuot
  minchaTest(new Date(2021,4,17), 17, 45)

  # 1st Day of Shabuot on Ereb Shabbat
  minchaTest(new Date(2020,4,29), 18, 30)

  # 2nd Day of Shabuot
  minchaTest(new Date(2021,4,18), 18, 55)

  # 2nd Day of Shabuot on Shabbat
  minchaTest(new Date(2020,4,30), 18, 35)

  # Ereb 9 Ab
  minchaTest(new Date(2017,6,31), 18, 25)

  # Ereb 9 Ab on Shabbat
  minchaTest(new Date(2016,7,13), 17, 40)

  # 9 Ab
  minchaTest(new Date(2017,7,1), 18, 35)

  # 9 Ab postponed
  minchaTest(new Date(2016,7,14), 18, 35)

  # Ereb Rosh Hashana
  minchaTest(new Date(2016,9,2), 18, 35)

  # Ereb Rosh Hashana on Ereb Shabbat
  minchaTest(new Date(2020,8,18), 18, 25)

  # 1st Day of Rosh Hashana
  minchaTest(new Date(2016,9,3), 18, 20)

  # 1st Day of Rosh Hashana on Shabbat
  minchaTest(new Date(2020,8,19), 18, 20)

  # 2nd Day of Rosh Hashana
  minchaTest(new Date(2016,9,4), 18, 40)

  # 2nd Day of Rosh Hashana on Ereb Shabbat
  minchaTest(new Date(2014,8,26), 18, 20)

  # Ereb Yom Kippur
  minchaTest(new Date(2016,9,11), 15, 30)

  # Ereb Yom Kippur on Ereb Shabbat
  minchaTest(new Date(2017,8,29), 15, 30)

  # Yom Kippur
  minchaTest(new Date(2016,9,12), 16, 5)

  # Yom Kippur on Shabbat
  minchaTest(new Date(2017,8,30), 16, 5)

  # Ereb Sukkot
  minchaTest(new Date(2017,9,4), 18, 55)

  # Ereb Sukkot on Ereb Shabbat (summer)
  minchaTest(new Date(2020,9,2), 18, 45)

  # Ereb Sukkot on Ereb Shabbat (winter)
  minchaTest(new Date(2020,9,2), 17, 45, 18)

  # 1st Day of Sukkot
  minchaTest(new Date(2017,9,5), 18, 55)

  # 1st Day of Sukkot on Shabbat
  minchaTest(new Date(2020,9,3), 18, 55)

  # 2nd Day of Sukkot
  minchaTest(new Date(2016,9,18), 18, 55)

  # 2nd Day of Sukkot on Ereb Shabbat (summer)
  minchaTest(new Date(2014,9,10), 18, 40)

  # 2nd Day of Sukkot on Ereb Shabbat (winter)
  minchaTest(new Date(2014,9,10), 17, 40, 18)

  # Asarah B'Tebet
  minchaTest(new Date(2015,0,1), 18, 50)

  # Asarah B'Tebet on Ereb Shabbat
  minchaTest(new Date(2013,11,13), 18, 35)

  # Taanit Ester
  minchaTest(new Date(2016,2,23), 18, 45)
