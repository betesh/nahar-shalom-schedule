//= require ../vendor/suncalc
//= require ../site/hebrewDateExtensions

SunCalc.addTime(-8.5, 'smallStars3', 'setHaKochabim')
SunCalc.addTime(-16.1, 'magenAbrahamDawn', 'magenAbrahamDusk')
SunCalc.addTime(-10.2, 'earliestTallit', 'dusk10_2')

shaaZemani = (beginningOfDay, lengthOfDay, hour) ->
  beginningOfDay.add(lengthOfDay * hour / 12.0, 'seconds')

class Zmanim
  constructor: (gregorianDate, coordinates) ->
    @gregorianDate = moment(gregorianDate).toDate()
    @gregorianDate.setHours(12)
    @zmanim = SunCalc.getTimes(@gregorianDate, coordinates.latitude, coordinates.longitude)
  shaaZemaniGra: (hour) ->
    beginningOfDay = moment(@zmanim.sunrise)
    lengthOfDay = (@zmanim.sunset - @zmanim.sunrise) / 1000
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbrahamDegrees: (hour) ->
    beginningOfDay = moment(@magenAbrahamDawn())
    lengthOfDay = (@zmanim.magenAbrahamDusk - @zmanim.magenAbrahamDawn) / 1000.0
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbrahamFixedMinutes: (hour) ->
    beginningOfDay = moment(@zmanim.sunrise).subtract(72, 'minutes')
    lengthOfDay = (@zmanim.sunset - @zmanim.sunrise) / 1000 + 144 * 60
    shaaZemani(beginningOfDay, lengthOfDay, hour)
  shaaZemaniMagenAbraham: (hour) -> moment.min(@shaaZemaniMagenAbrahamDegrees(hour), @shaaZemaniMagenAbrahamFixedMinutes(hour))
  magenAbrahamDawn: -> @_magenAbrahamDawn ?= moment(@zmanim.magenAbrahamDawn)
  earliestTallit: -> @_earliestTallit ?= moment(@zmanim.earliestTallit)
  sunrise: -> @_sunrise ?= moment(@zmanim.sunrise)
  sofZmanKeriatShema: -> @_sofZmanKeriatShema ?= @shaaZemaniMagenAbraham(3)
  chatzot: -> @_chatzot ?= moment(@zmanim.solarNoon)
  samuchLeminchaKetana: -> @_samuchLeminchaKetana ?= @shaaZemaniMagenAbraham(9)
  plag: -> @_plag ?= @shaaZemaniGra(10.75)
  hadlakatNerot: -> # TODO: test
    if (new HebrewDate(@gregorianDate)).hasHadlakatNerot() then moment(@sunset()).subtract(19.5, 'minutes').seconds(0) else null
  sunset: -> @_sunset ?= moment(@zmanim.sunset)
  setHaKochabimGeonim: -> @_setHaKochabimGeonim ?= @shaaZemaniGra(12.225).add(1, 'minute')
  setHaKochabim3Stars: -> @_setHaKochabim3Stars ?= moment(@zmanim.setHaKochabim)

(exports ? this).Zmanim = Zmanim
