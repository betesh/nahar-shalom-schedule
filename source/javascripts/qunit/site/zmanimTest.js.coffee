#= require site/zmanim
#= require qunit/helpers

zmanimTest = ->
  assertTimeEqual = QunitHelpers.assertTimeEqual
  date = new Date(2016,4,3)
  boston = { latitude: 42.3601, longitude: -71.0589}
  QUnit.test "Zmanim test for #{moment(date).format("YYYY-MM-DD")} in Boston", (assert) ->
    actual = new Zmanim(date, boston)
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(0), moment(date).hour(4).minute(0).second(21), "0 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(1), moment(date).hour(5).minute(27).second(21), "1 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(2), moment(date).hour(6).minute(54).second(20), "2 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(3), moment(date).hour(8).minute(21).second(19), "3 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(4), moment(date).hour(9).minute(48).second(19), "4 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(5), moment(date).hour(11).minute(15).second(18), "5 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(6), moment(date).hour(12).minute(42).second(17), "6 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(7), moment(date).hour(14).minute(9).second(17), "7 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(8), moment(date).hour(15).minute(36).second(16), "8 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(9), moment(date).hour(17).minute(3).second(15), "9 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(10), moment(date).hour(18).minute(30).second(15), "10 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(11), moment(date).hour(19).minute(57).second(14), "11 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamDegrees(12), moment(date).hour(21).minute(24).second(14), "12 hours with Magen Abraham Degrees"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(0), moment(date).hour(4).minute(25).second(22), "0 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(1), moment(date).hour(5).minute(48).second(11), "1 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(2), moment(date).hour(7).minute(11).second(0), "2 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(3), moment(date).hour(8).minute(33).second(50), "3 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(4), moment(date).hour(9).minute(56).second(39), "4 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(5), moment(date).hour(11).minute(19).second(28), "5 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(6), moment(date).hour(12).minute(42).second(17), "6 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(7), moment(date).hour(14).minute(5).second(7), "7 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(8), moment(date).hour(15).minute(27).second(56), "8 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(9), moment(date).hour(16).minute(50).second(45), "9 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(10), moment(date).hour(18).minute(13).second(35), "10 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(11), moment(date).hour(19).minute(36).second(24), "11 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbrahamFixedMinutes(12), moment(date).hour(20).minute(59).second(13), "12 hours with Magen Abraham Fixed Minutes"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(0), moment(date).hour(4).minute(0).second(21), "0 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(1), moment(date).hour(5).minute(27).second(21), "1 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(2), moment(date).hour(6).minute(54).second(20), "2 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(3), moment(date).hour(8).minute(21).second(19), "3 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(4), moment(date).hour(9).minute(48).second(19), "4 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(5), moment(date).hour(11).minute(15).second(18), "5 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(6), moment(date).hour(12).minute(42).second(17), "6 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(7), moment(date).hour(14).minute(5).second(7), "7 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(8), moment(date).hour(15).minute(27).second(56), "8 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(9), moment(date).hour(16).minute(50).second(45), "9 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(10), moment(date).hour(18).minute(13).second(35), "10 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(11), moment(date).hour(19).minute(36).second(24), "11 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniMagenAbraham(12), moment(date).hour(20).minute(59).second(13), "12 hours with Earliest Magen Abraham"
    assertTimeEqual assert, actual.shaaZemaniGra(0), moment(date).hour(5).minute(37).second(22), "0 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(1), moment(date).hour(6).minute(48).second(11), "1 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(2), moment(date).hour(7).minute(59).second(0), "2 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(3), moment(date).hour(9).minute(9).second(50), "3 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(4), moment(date).hour(10).minute(20).second(39), "4 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(5), moment(date).hour(11).minute(31).second(28), "5 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(6), moment(date).hour(12).minute(42).second(17), "6 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(7), moment(date).hour(13).minute(53).second(7), "7 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(8), moment(date).hour(15).minute(3).second(56), "8 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(9), moment(date).hour(16).minute(14).second(45), "9 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(10), moment(date).hour(17).minute(25).second(35), "10 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(11), moment(date).hour(18).minute(36).second(24), "11 hours with Gra"
    assertTimeEqual assert, actual.shaaZemaniGra(12), moment(date).hour(19).minute(47).second(13), "12 hours with Gra"
    assertTimeEqual assert, actual.magenAbrahamDawn(0), moment(date).hour(4).minute(0).second(21), "Magen Abraham Dawn"
    assertTimeEqual assert, actual.earliestTallit(), moment(date).hour(4).minute(40).second(7), "Earliest Tallit"
    assertTimeEqual assert, actual.sunrise(), moment(date).hour(5).minute(37).second(22), "Sunrise"
    assertTimeEqual assert, actual.sofZmanKeriatShema(), moment(date).hour(8).minute(21).second(19), "Latest time for Keriat Shema"
    assertTimeEqual assert, actual.chatzot(), moment(date).hour(12).minute(42).second(17), "Chatzot Hayom"
    assertTimeEqual assert, actual.samuchLeminchaKetana(), moment(date).hour(16).minute(50).second(45), "One half hour before Mincha Ketana"
    assertTimeEqual assert, actual.plag(), moment(date).hour(18).minute(18).second(42), "Plag Hamincha"
    assertTimeEqual assert, actual.sunset(), moment(date).hour(19).minute(47).second(13), "Sunset"
    assertTimeEqual assert, actual.setHaKochabimGeonim(), moment(date).hour(20).minute(4).second(0), "Set HaKochabim according to the Geonim"
    assertTimeEqual assert, actual.setHaKochabim3Stars(), moment(date).hour(20).minute(33).second(39), "Set HaKochabim according to the custom in the USA"
  winterDate = new Date(2016,0,3)
  QUnit.test "Zmanim test for #{moment(winterDate).format("YYYY-MM-DD")} in Boston", (assert) ->
    actual = new Zmanim(winterDate, boston)
    assertTimeEqual assert, actual.sunset(), moment(winterDate).hour(16).minute(24).second(31), "Sunset"
    assertTimeEqual assert, actual.setHaKochabimGeonim(), moment(winterDate).hour(16).minute(42).second(0), "Set HaKochabim according to the Geonim"
  summerDate = new Date(2016,6,3)
  QUnit.test "Zmanim test for #{moment(summerDate).format("YYYY-MM-DD")} in Boston", (assert) ->
    actual = new Zmanim(summerDate, boston)
    assertTimeEqual assert, actual.sunset(), moment(summerDate).hour(20).minute(25).second(40), "Sunset"
    assertTimeEqual assert, actual.setHaKochabimGeonim(), moment(summerDate).hour(20).minute(43).second(0), "Set HaKochabim according to the Geonim"

$ ->
  zmanimTest()
