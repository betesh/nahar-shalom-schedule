###
    MIT LICENSE
    (c) Isaac Betesh
    refactored from https://github.com/betesh/hebcal/
###

### Constant for calculating dates of other holidays given a known date of Pesach ###
SHAVUOT_DISTANCE = 50
SUKKOT_DISTANCE = 59 * 3
PURIM_DISTANCE = -30
STANDARD_HANUKAH_DISTANCE = 59 * 4 + 10
FAST_AB_DISTANCE = 59 * 2 - 6
STANDARD_10_TEVET_DISTANCE = 59 * 4 + 30 - 5
YOM_TOB_START_RANGES = [0,6,SHAVUOT_DISTANCE, SUKKOT_DISTANCE - 14, SUKKOT_DISTANCE, SUKKOT_DISTANCE + 7]

get_distance = (date1, date2) ->
  hours = (date2 - date1) / 60 / 60 / 1000
  if (hours % 24) in [1, -23]
    hours -= 1
  else if (hours % 24) in [-1, 23]
    hours += 1
  hours / 24

pesach_distance = (date) -> get_distance(pesach_in_gregorian_year(date.getFullYear()), date)

is_distance_in_range = (distance, begin, length) -> distance >= begin && distance <= begin + length - 1

get_pesach_and_year_length = (date) ->
  year = date.getFullYear()
  pesach1 = pesach_in_gregorian_year(year)
  if (get_distance(pesach1, date) < -59)
    pesach2 = pesach1
    pesach1 = pesach_in_gregorian_year(year - 1)
  else
    pesach2 = pesach_in_gregorian_year(year + 1)
  pesach_date: pesach1, year_length: get_distance(pesach1, pesach2)

rosh_hodesh_distances = (year_length) ->
  distances =                  [   -59 + 15,    -59 + 16,    -59 + 30 + 15]
  distances = distances.concat [         15,          16,          30 + 15]
  distances = distances.concat [    59 + 15,     59 + 16,     59 + 30 + 15]
  distances = distances.concat [2 * 59 + 15, 2 * 59 + 16]
  distances = distances.concat [3 * 59 + 15, 3 * 59 + 16, 3 * 59 + 30 + 15]
  if year_length in [353, 383]
    distances = distances.concat([4 * 59 + 15])
    distances = distances.concat([4 * 59 + 30 + 14])
    distances = distances.concat([5 * 59 + 14, 5 * 59 + 15]) if (383 == year_length)
  else if year_length in [354, 384]
    distances = distances.concat([4 * 59 + 15, 4 * 59 + 16])
    distances = distances.concat([4 * 59 + 30 + 15])
    distances = distances.concat([5 * 59 + 15, 5 * 59 + 16]) if (384 == year_length)
  else if year_length in [355, 385]
    distances = distances.concat([3 * 59 + 30 + 16])
    distances = distances.concat([4 * 59 + 16, 4 * 59 + 17])
    distances = distances.concat([4 * 59 + 30 + 16])
    distances = distances.concat([5 * 59 + 16, 5 * 59 + 17]) if (385 == year_length)
  distances

fast_of_tevet_distance = (year_length) ->
  if year_length in [353, 383]
    STANDARD_10_TEVET_DISTANCE - 1
  else if year_length in [355, 385]
    STANDARD_10_TEVET_DISTANCE + 1
  else
    STANDARD_10_TEVET_DISTANCE

begin_tal_umatar = (date) -> date.getMonth() == 11 && date.getDate() == (6 - parseInt(new Date(date.getFullYear() + 1, 1, 29).getMonth()))

class HebrewDate
  constructor: (date) ->
    @pesach_distance = pesach_distance(date)
    @day_of_week = date.getDay()
    {@year_length, @pesach_date} = get_pesach_and_year_length(date)
    @past_pesach_distance = get_distance(@pesach_date, date)
    @rosh_hodesh_distances = rosh_hodesh_distances(@year_length)
    @begin_tal_umatar = begin_tal_umatar(date)
    @year = date.getFullYear() + 3760 + (if @pesach_distance > SUKKOT_DISTANCE - 14 then 1 else 0)
  isPesach: -> is_distance_in_range(@pesach_distance, 0, 8)
  isShavuot: -> is_distance_in_range(@pesach_distance, SHAVUOT_DISTANCE, 2)
  isElul: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 43, 29)
  isRoshHashanah: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 14, 2)
  is10DaysOfTeshuvah: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 12, 7)
  isYomKippur: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 5, 1)
  isSukkot: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE, 9)
  isMoed: -> is_distance_in_range(@pesach_distance, 2, 4) || is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE + 2, 5)
  isRegel: -> @isPesach() || @isShavuot() || @isSukkot()
  isYomTov: -> true in (is_distance_in_range(@pesach_distance, start_range, 2) for start_range in YOM_TOB_START_RANGES)
  ### Note that Yom Kippur is not a Yom Tov ###
  isPurim: -> is_distance_in_range(@pesach_distance, PURIM_DISTANCE, 1)
  isChanukkah: ->
    distance = STANDARD_HANUKAH_DISTANCE + (if @year_length in [355, 385] then 1 else 0)
    is_distance_in_range(@past_pesach_distance, distance, 8)
  is_fast_with_sunday_postponement: (distance) -> (!@isShabbat() && is_distance_in_range(@pesach_distance, distance, 1)) || (0 == @day_of_week && is_distance_in_range(@pesach_distance, distance + 1, 1))
  is9Av: -> @is_fast_with_sunday_postponement(FAST_AB_DISTANCE)
  is17Tammuz: -> @is_fast_with_sunday_postponement(FAST_AB_DISTANCE - 21)
  isFastOfGedaliah: -> @is_fast_with_sunday_postponement(SUKKOT_DISTANCE - 12)
  isTaanitEster: -> (!@isShabbat() && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 1, 1)) || (4 == @day_of_week && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 3, 1))
  is10Tevet: -> is_distance_in_range(@past_pesach_distance, fast_of_tevet_distance(@year_length), 1)
  isTaanit: -> @is9Av() || @is17Tammuz() || @isFastOfGedaliah() || @isTaanitEster() || @is10Tevet()
  isRoshHodesh: -> @past_pesach_distance in @rosh_hodesh_distances
  isPesachSheni: -> is_distance_in_range(@pesach_distance, 29, 1)
  isLagLaomer: -> is_distance_in_range(@pesach_distance, 33, 1)
  isBeginTalUmatar: -> @begin_tal_umatar
  isShabbat: -> 6 == @day_of_week
  isErebShabbat: -> 5 == @day_of_week
  isEreb9Ab: -> (!@isErebShabbat() && is_distance_in_range(@pesach_distance, FAST_AB_DISTANCE - 1, 1)) || (@isShabbat() && is_distance_in_range(@pesach_distance, FAST_AB_DISTANCE, 1))
  isErebYomKippur: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 6, 1)
  is6thDayOfPesach: -> is_distance_in_range(@pesach_distance, 5, 1)
  is7thDayOfPesach: -> is_distance_in_range(@pesach_distance, 6, 1)
  isErebRoshHashana: -> is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - 15, 1)
  isErebYomTob: -> true in (is_distance_in_range(@pesach_distance, start_range - 1, 1) for start_range in YOM_TOB_START_RANGES)
  is1stDayOfYomTob: -> true in (is_distance_in_range(@pesach_distance, start_range, 1) for start_range in YOM_TOB_START_RANGES)
  is1stDayOfShabuot: -> is_distance_in_range(@pesach_distance, SHAVUOT_DISTANCE, 1)
  isTuBAb: -> is_distance_in_range(@pesach_distance, FAST_AB_DISTANCE + 6, 1)
  isMaharHodesh: -> @isShabbat() && !@isRoshHodesh() && (@past_pesach_distance + 1) in @rosh_hodesh_distances
  isShushanPurim: -> is_distance_in_range(@pesach_distance, PURIM_DISTANCE + 1, 1)
  isPurimKatan: -> @year_length > 380 && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 30, 1)
  isShushanPurimKatan: -> @year_length > 380 && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 30, 1)
  isShabbatMevarechim: -> @isShabbat() && !@isRoshHodesh() && (true in (((@past_pesach_distance + n) in @rosh_hodesh_distances) for n in [1..7]))
  isShabbatSheqalim: -> @isShabbat() && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 19, 7)
  isShabbatZachor: -> @isShabbat() && is_distance_in_range(@pesach_distance, PURIM_DISTANCE - 7, 7)
  isShabbatParah: -> @isShabbat() && is_distance_in_range(@pesach_distance, -27, 7)
  isShabbatHaHodesh: -> @isShabbat() && is_distance_in_range(@pesach_distance, -20, 7)
  isShabbatHaGadol: -> @isShabbat() && is_distance_in_range(@pesach_distance, -7, 7)
  isHachrazatTaanit: -> @isShabbat() && (is_distance_in_range(@pesach_distance, FAST_AB_DISTANCE - 27, 7) || is_distance_in_range(@past_pesach_distance, fast_of_tevet_distance(@year_length) - 7, 7))
  isErubTabshilin: -> @day_of_week in [3,4] && @isErebYomTob()
  isHataratNedarim: -> true in ((is_distance_in_range(@pesach_distance, SUKKOT_DISTANCE - n, 1)) for n in [55,45,15,6])
  isTuBiShvat: -> is_distance_in_range(@pesach_distance, (if @year_length > 380 then -89 else -59), 1)
  day_of_year: -> @pesach_distance - (SUKKOT_DISTANCE - 14)

HebrewDate.prototype.isRoshHaShana = HebrewDate.prototype.isRoshHashana = HebrewDate.prototype.isRoshHaShanah = HebrewDate.prototype.isRoshHashanah
HebrewDate.prototype.isYomTob = HebrewDate.prototype.isYomTov
HebrewDate.prototype.isRoshChodesh = HebrewDate.prototype.isRoshHodesh
HebrewDate.prototype.isLagBaOmer = HebrewDate.prototype.isLagLaOmer = HebrewDate.prototype.isLagBaomer = HebrewDate.prototype.isLagLaomer
HebrewDate.prototype.isHanuka = HebrewDate.prototype.isHanukka = HebrewDate.prototype.isHanukah = HebrewDate.prototype.isHanukkah = HebrewDate.prototype.isChanuka = HebrewDate.prototype.isChanukka = HebrewDate.prototype.isChanukah = HebrewDate.prototype.isChanukkah
HebrewDate.prototype.is17Tamuz = HebrewDate.prototype.is17Tammuz
HebrewDate.prototype.is9Ab = HebrewDate.prototype.is9Av
HebrewDate.prototype.isTzomGedalia = HebrewDate.prototype.isTzomGedaliah = HebrewDate.prototype.isFastOfGedalia = HebrewDate.prototype.isFastOfGedaliah
HebrewDate.prototype.isTaanitEsther = HebrewDate.prototype.isTaanitEster

window.HebrewDate = HebrewDate

$ -> alert "Error: hebrew_date.js requires passover.js" unless window.pesach_in_gregorian_year
