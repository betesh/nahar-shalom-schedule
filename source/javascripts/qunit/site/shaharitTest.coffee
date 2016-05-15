//= require site/shaharit
//= require qunit/helpers

occasionsThatDoNotAffectShaharit = ["HataratNedarim", "ErubTabshilin", "Regel", "ShabbatHaGadol", "MaharHodesh", "ShabbatMevarechim", "ErebYomTob"]

assertTimeEqual = QunitHelpers.assertTimeEqual

shaharitTest = (gregorianDate, expected, sofZmanKeriatShemaMinute = 31) ->
  hebrewDate = new HebrewDate(gregorianDate)
  sunrise = moment(gregorianDate).hour(6).minute(8).seconds(8)
  sofZmanKeriatShema = moment(gregorianDate).hour(9).minute(sofZmanKeriatShemaMinute).seconds(9)
  events = hebrewDate.occasions().filter((e) -> (-1 == occasionsThatDoNotAffectShaharit.indexOf(e))).join(" / ")
  QUnit.test "When sunrise is at #{sunrise.format("hh:mm:ss A")} and Sof Zman Keriat Shema is at #{sofZmanKeriatShema.format("hh:mm:ss A")}  on #{events}", (assert) ->
    shaharit = new Shaharit(hebrewDate, sunrise, sofZmanKeriatShema)
    if expected.selihot?
      assertTimeEqual assert, shaharit.selihot(), expected.selihot, "Selihot"
    else
      assert.equal shaharit.selihot(), null, "Shaharit.selihot() does not return a time"
    assert.equal shaharit.korbanot().length, expected.korbanot.length, "There are #{expected.korbanot.length} times for Korbanot"
    for i in [0...(expected.korbanot.length)]
      assertTimeEqual assert, shaharit.korbanot()[i], expected.korbanot[i], "Korbanot ##{i}"
    assert.equal shaharit.hodu().length, expected.hodu.length, "There are #{expected.korbanot.length} times for Hodu"
    for i in [0...(expected.hodu.length)]
      assertTimeEqual assert, shaharit.hodu()[i], expected.hodu[i], "Hodu ##{i}"
    if expected.nishmat?
      assertTimeEqual assert, shaharit.nishmat(), expected.nishmat, "Nishmat"
    else
      assert.equal shaharit.nishmat(), null, "Shaharit.nishmat() does not return a time"
    assertTimeEqual assert, shaharit.yishtabach(), expected.yishtabach,"Yishtabach"
    assertTimeEqual assert, shaharit.amidah(), expected.amidah,"Amidah"

shaharitYomTobTest  = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(11), moment(date).hours(7).minutes(45)],
    hodu: [moment(date).hours(5).minutes(26), moment(date).hours(8).minutes(0)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitPesachTest  = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(11), moment(date).hours(8).minutes(45)],
    hodu: [moment(date).hours(5).minutes(26), moment(date).hours(9).minutes(0)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitShabuotTest  = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(2)],
    hodu: [moment(date).hours(5).minutes(17)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitYomKippurTest = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(4).minutes(58), moment(date).hours(7).minutes(0)],
    hodu: [moment(date).hours(5).minutes(13), moment(date).hours(7).minutes(15)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitWeekdayTest = (date, selihot) ->
  shaharitTest date,
    selihot: selihot,
    korbanot: [moment(date).hours(5).minutes(32)],
    hodu: [moment(date).hours(5).minutes(48)],
    yishtabach: moment(date).hours(5).minutes(59),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitShabbatTest815  = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(13), moment(date).hours(8).minutes(15)],
    hodu: [moment(date).hours(5).minutes(28), moment(date).hours(8).minutes(30)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

shaharitShabbatTest745  = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(13), moment(date).hours(7).minutes(45)],
    hodu: [moment(date).hours(5).minutes(28), moment(date).hours(8).minutes(0)],
    nishmat: moment(date).hours(5).minutes(51),
    yishtabach: moment(date).hours(5).minutes(55),
    amidah: moment(date).hours(6).minutes(8).seconds(8),
    13

shaharitHolHaMoedTest = (date) ->
  shaharitTest date,
    selihot: null,
    korbanot: [moment(date).hours(5).minutes(30)],
    hodu: [moment(date).hours(5).minutes(46)],
    yishtabach: moment(date).hours(5).minutes(59),
    amidah: moment(date).hours(6).minutes(8).seconds(8)

$ ->
  # 1st Day of Pesach
  shaharitPesachTest(new Date(2017,3,11))

  # 2nd Day of Pesach
  shaharitPesachTest(new Date(2017,3,12))

  # Holl Hamoed
  shaharitHolHaMoedTest(new Date(2017,3,16))

  # 7th Day of Pesach
  shaharitYomTobTest(new Date(2017,3,17))

  # 8th Day of Pesach
  shaharitYomTobTest(new Date(2017,3,18))

  # 1st Day of Shabuot
  shaharitShabuotTest(new Date(2021,4,17))

  # 2nd Day of Shabuot
  shaharitYomTobTest(new Date(2021,4,18))

  # 1st Day of Rosh Hashana
  shaharitYomTobTest(new Date(2016,9,3))

  # Rosh Hodesh Elul
  shaharitWeekdayTest(new Date(2016,8,4))

  # Elul
  erebRoshHashana = new Date(2016,9,2)
  shaharitWeekdayTest(erebRoshHashana, moment(erebRoshHashana).hours(4).minutes(42))

  # Aseret Yemei Teshubat
  erebKippur = new Date(2016,9,11)
  shaharitWeekdayTest(erebKippur, moment(erebKippur).hours(4).minutes(36))

  # Yom Kippur
  shaharitYomKippurTest(new Date(2016,9,12))

  # Shabbat (7:45)
  shaharitShabbatTest745(new Date(2016,2,12))

  # Shabbat (8:15)
  shaharitShabbatTest815(new Date(2016,2,19))

  # Shabbat Shubah
  shaharitShabbatTest815(new Date(2016,9,8))

  # Weekday
  shaharitWeekdayTest(new Date(2016,4,9))
