HebrewDate.prototype.isErebPesach = -> @monthAndRangeAre('NISAN', [14])
HebrewDate.prototype.is1stDayOfPesach = -> @monthAndRangeAre('NISAN', [15])
HebrewDate.prototype.is2ndDayOfPesach = -> @monthAndRangeAre('NISAN', [16])
HebrewDate.prototype.is8thDayOfPesach = -> @monthAndRangeAre('NISAN', [22])
HebrewDate.prototype.isErebShabuot = -> @monthAndRangeAre('SIVAN', [5])
HebrewDate.prototype.isEreb9Ab = HebrewDate.prototype.isEreb9Av
HebrewDate.prototype.isErebRoshHashana = -> @monthAndRangeAre('ELUL', [29])
HebrewDate.prototype.isErebSukkot = -> @monthAndRangeAre('TISHRI', [14])
HebrewDate.prototype.isHoshanaRaba = -> @monthAndRangeAre('TISHRI', [21])
HebrewDate.prototype.isSheminiAseret = -> @monthAndRangeAre('TISHRI', [22..23])
HebrewDate.prototype.isBirkatHaIlanot = -> !@isShabbat() && @monthAndRangeAre('NISAN', if 0 == @gregorianDate.getDay() then [1..2] else [1])
HebrewDate.prototype.isTefilatHaShelah = -> @monthAndRangeAre('IYAR', [29])
HebrewDate.prototype.is2ndDayOfYomTob = -> @is2ndDayOfPesach() || @is8thDayOfPesach() || @monthAndRangeAre('SIVAN', [7]) || @monthAndRangeAre('TISHRI', [2,16,23])
HebrewDate.prototype.isErebHoshanaRaba = -> @monthAndRangeAre('TISHRI', [20])

time_format = (time) -> time.format('h:mm') if time?
round_down_to_5_minutes = (time) -> time.subtract(time.minute() % 5, 'minutes')
minutes_before_event = (event, minutes)-> round_down_to_5_minutes(moment(event).subtract(minutes, 'minutes'))
recent_hadlakat_nerot = null;

portion_of_day = (zmanim, ratio) ->
  sunrise = moment(zmanim.sunrise)
  sunrise.add(moment(zmanim.sunset).diff(sunrise, 'minutes') * ratio, 'minutes')

show_mosaei_yom_tob = (date, zmanim) -> # This code is no longer called from anywhere
  $('.mosaei-yom-tob').removeClass('hidden').find('.date').html(moment.weekdays()[date.weekday()])
  $('.yom-tob-ends').html(set_hakochabim(zmanim))

class Schedule
  constructor: (day_iterator) ->
    @hebrew_date = new HebrewDate(day_iterator.toDate())
    @zmanim = SunCalc.getTimes(moment(day_iterator).toDate().setHours(12), window.config.latitude, window.config.longitude)
    @sunset = moment(@zmanim.sunset).subtract(30, 'second')
  today: -> moment(@sunset)
  tonight_is_yom_tob: -> @hebrew_date.isErebYomTob() || @hebrew_date.is1stDayOfYomTob()
  yom_tob_that_we_can_pray_at_plag: -> @hebrew_date.is7thDayOfPesach() || @hebrew_date.is1stDayOfShabuot()
  last_time_for_shema: -> @_last_time_for_shema ?= moment.min(
      moment(@zmanim.magen_abraham_dawn).add((@zmanim.magen_abraham_dusk - @zmanim.magen_abraham_dawn) / 4000, 'seconds'),
      moment(@zmanim.sunrise).subtract(36, 'minutes').add((@zmanim.sunset - @zmanim.sunrise) / 4000, 'seconds'),
    )
  shema_is_before_9_am: -> @last_time_for_shema().isBefore(@today().hour(if (@hebrew_date.is1stDayOfPesach() || @hebrew_date.is2ndDayOfPesach()) then 10 else 9).minute(0))
  mincha_minutes_before_sunset_on_shabbat: -> if @hebrew_date.isEreb9Ab() then 100 else 45
  mincha_minutes_before_sunset_on_rosh_hashana: -> if @hebrew_date.is1stDayOfYomTob() || @hebrew_date.isErebShabbat() then 60 else 40
  mincha_minutes_before_sunset_on_taanit: -> switch
    when @hebrew_date.is9Ab() || @hebrew_date.isErebShabbat() then 45
    when @hebrew_date.isTaanitEster() then 35
    else 30
  arbit_minutes_after_set_hakochabim_on_mosaei_shabbat: -> if @hebrew_date.isEreb9Ab() then 0 else 10
  mincha_on_shabbat: -> minutes_before_event(@sunset, @mincha_minutes_before_sunset_on_shabbat())
  arbit_on_mosaei_shabbat: -> moment(@zmanim.set_hakochabim).add(@arbit_minutes_after_set_hakochabim_on_mosaei_shabbat(), 'minutes')
  afternoon_shiur: -> $(".#{@chag()}.afternoon-shiur").removeClass("hidden").find(".time").html(time_format(moment(@mincha()).subtract(1, 'hour')))
  samuch_lemincha_ketana: -> portion_of_day(@zmanim, 0.75)
  plag: -> moment(@_plag ?= portion_of_day(@zmanim, 43.0/48.0))
  plag_is_before_615: -> @plag().isBefore(@today().hour(18).minute(15))
  set_hakochabim: -> time_format(moment(@zmanim.set_hakochabim))
  rabbenu_tam: -> time_format(moment(@sunset).add(73, 'minute'))
  set_hakochabim_geonim: -> # 13.5 fixed minutes after sunset, rounded to end of minute
    moment(@sunset).add('14', 'minutes')
  chag: -> @_chag ?= (
    name_of_chag = switch
      when (@hebrew_date.isErebPesach() && !@hebrew_date.isShabbat()) || @hebrew_date.is1stDayOfPesach() || @hebrew_date.is2ndDayOfPesach() then 'pesach-first-days'
      when @hebrew_date.is6thDayOfPesach() || @hebrew_date.is7thDayOfPesach() || @hebrew_date.is8thDayOfPesach() then 'pesach-last-days'
      when (@hebrew_date.isErebShabuot() && !@hebrew_date.isShabbat()) || @hebrew_date.isShabuot() then 'shabuot'
      when @hebrew_date.isErebRoshHashana() || @hebrew_date.isRoshHashana() then 'rosh-hashana'
      when @hebrew_date.isErebSukkot() || (@hebrew_date.isSukkot() && @hebrew_date.isYomTob() && !@hebrew_date.isSheminiAseret()) then 'sukkot-first-days'
      when @hebrew_date.isHoshanaRaba() || @hebrew_date.isSheminiAseret() || (@hebrew_date.isErebHoshanaRaba() && !@hebrew_date.isShabbat()) then 'sukkot-last-days'
      when @hebrew_date.isErebYomKippur() || @hebrew_date.isYomKippur() then 'yom-kippur'
      when (@hebrew_date.isErebShabbat() && !@hebrew_date.isPurim()) || @hebrew_date.isShabbat() then 'shabbat'
      when @hebrew_date.isTaanit() && !@hebrew_date.is9Ab() then 'taanit'
      when @hebrew_date.isPurim() then 'purim-table'
      when (@hebrew_date.is9Ab() || @hebrew_date.isEreb9Ab()) && !@hebrew_date.isShabbat() then 'chabob'
      else console.warn "This should never happen!"
    rishon_or_sheni = switch
      when ((@hebrew_date.isErebYomTob() || @hebrew_date.isEreb9Ab()) && !@hebrew_date.isShabbat()) || @hebrew_date.isErebYomKippur() || (@hebrew_date.isErebShabbat() && !@hebrew_date.isPurim() && !@hebrew_date.isYomTob()) then '.eve'
      when @hebrew_date.is1stDayOfYomTob() then '.first'
      when @hebrew_date.is2ndDayOfYomTob() then '.second'
      when @hebrew_date.isShabbat() || @hebrew_date.isYomKippur() || @hebrew_date.isTaanit() then '.day'
      when @hebrew_date.isPurim() then  '.purim-row'
      when @hebrew_date.isErebHoshanaRaba() then '.tiqun-leil-hoshana-raba'
      else console.warn "This should never happen!"
    "#{name_of_chag} #{rishon_or_sheni}")
  show_chatzot: -> $(".#{@chag()}.chatzot").removeClass('hidden').find('.time').html(@chatzot())
  set_date: ->
    $(".#{@chag().split('.')[0]}").not('.event').removeClass('hidden')
    $(".#{@chag()} .date").html(@sunset.format('D MMM'))
    $(".#{@chag()} .dow").html(if @hebrew_date.isShabbat() then "שַׁבָּת" else @sunset.format('dddd'))
  hadlakat_nerot_schedule: ->
    @set_date()
    $(".#{@chag()}.hadlakat-nerot").removeClass("hidden").find(".time").html(@hadlakat_nerot_text())
    @show_chatzot() if @hebrew_date.isErebPesach() || @hebrew_date.is1stDayOfPesach()
    $(".#{@chag()}.tiqun").removeClass('hidden').find('.time').html(@today().hour(0).minute(0).format('h:mm A')) if @hebrew_date.isErebShabuot()
  rabbenu_tam_schedule: ->
    $(".#{@chag()}.ends").removeClass("hidden").find(".time").html(@set_hakochabim())
    $(".#{@chag()}.rabbenu-tam").removeClass("hidden").find(".time").html(@rabbenu_tam()) if @hebrew_date.isShabbat() || @hebrew_date.isYomKippur()
    half_hour_after_rabbenu_tam = round_down_to_5_minutes(moment(@sunset).add(101, 'minute'))
    unless @hebrew_date.isShabbatZachor() && 13 == @hebrew_date.dayOfMonth
      if half_hour_after_rabbenu_tam.isBefore(@today().hour(20).minute(16))
        $(".#{@chag()}.abot-ubanim").removeClass('hidden').find(".time").html(time_format(half_hour_after_rabbenu_tam))
  chatzot: -> time_format(moment(@zmanim.solarNoon))
  taanit_schedule: ->
    @set_date()
    name = switch
      when @hebrew_date.is17Tamuz() then "Tamuz17"
      when @hebrew_date.is10Tevet() then "Tebet10"
      when @hebrew_date.isFastOfGedaliah() then "FastOfGedaliah"
      when @hebrew_date.isTaanitEster() then (if 13 == @hebrew_date.dayOfMonth then "TaanitEsterAndPurim" else "TaanitEster")
      when @hebrew_date.isPurim() then (if 0 == @hebrew_date.gregorianDate.getDay() then "PurimOnly" else null)
      when @hebrew_date.isEreb9Ab() || @hebrew_date.is9Ab() then null
      else console.warn "This should never happen!"
    $(".taanit th .#{name}").removeClass("hidden") if name?
    if @hebrew_date.isPurim()
      $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html("#{minutes_before_event(@zmanim.sunrise, -20).format('h:mm A')} <strong>and</strong> #{@today().hour(9).minute(30).format('h:mm A')}")
      $(".#{@chag()}.megilla").find(".dow, .date").attr("rowspan", if @hebrew_date.isErebShabbat() then 2 else 1)
      return
    fast_begins_row = $(".#{@chag()}.fast-begins").removeClass('hidden')
    if @hebrew_date.isEreb9Ab()
      fast_begins_row.find(".time").html(@sunset.format('h:mm A'))
    else if @hebrew_date.is9Ab()
      $(".#{@chag()}.chatzot .time").html(@chatzot())
      $(".#{@chag()}.chatzot").find(".dow, .date").attr("rowspan", if 0 == @hebrew_date.gregorianDate.getDay() then 3 else 2)
      $(".#{@chag()}.habdala").removeClass("hidden") if 0 == @hebrew_date.gregorianDate.getDay()
    else
      fast_begins_row.find(".dow, .date").attr("rowspan", if @hebrew_date.isTaanitEster() then (if 13 == @hebrew_date.dayOfMonth then 4 else 3) else 2)
      fast_begins_row.find(".time").html(moment(@zmanim.sunrise).subtract(73, 'minutes').format('h:mm A'))
    fast_ends = @set_hakochabim_geonim()
    $(".#{@chag()}.fast-ends").removeClass('hidden').find(".time").html(fast_ends.format('h:mm A'))
    if @hebrew_date.isTaanitEster()
      $(".#{@chag()}.mahasit-hashekel").removeClass('hidden')
      if 13 == @hebrew_date.dayOfMonth
        $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html(minutes_before_event(fast_ends, -7).format('h:mm A'))
  seudat_shelishit_time: -> if @tonight_is_yom_tob() then @samuch_lemincha_ketana() else @sunset
  shabbat_schedule: ->
    [add, remove] = if @hebrew_date.isShabbat() && (@hebrew_date.is1stDayOfPesach() || @hebrew_date.isShabuot() || @hebrew_date.isRoshHashana()) then [6,7] else [7,6]
    $(".#{@chag().split(" ")[0]}").removeClass("col-xs-#{add}").addClass("col-xs-#{remove}")
    @set_date()
    @hadlakat_nerot_schedule() if @tonight_is_yom_tob()
    if @hebrew_date.isShabbatZachor()
      $(".#{@chag()}.mi-chamocha").find(".dow, .date").attr("rowspan", if @shema_is_before_9_am() then 7 else 6)
      $(".#{@chag()}.mi-chamocha").removeClass('hidden').find('.time').html(time_format(@today().hour(7).minute(25)))
      $(".#{@chag()}.zachor").removeClass('hidden').find('.time').html("#{@today().hour(9).minute(45).format('h:mm A')} <strong>and</strong> #{@today().hour(14).minute(30).format('h:mm A')}")
      $(".#{@chag()}.afternoon-shiur").find(".dow, .date").addClass('hidden')
      $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html(minutes_before_event(@sunset, -100).format('h:mm A')) if 13 == @hebrew_date.dayOfMonth
    if @shema_is_before_9_am()
      $(".#{@chag()}.shema").removeClass('hidden').find('.time').html(time_format(@last_time_for_shema()))
      if @hebrew_date.isShabbatZachor()
        $(".#{@chag()}.shema").find(".dow, .date").addClass('hidden')
      else
        $(".#{@chag()}.afternoon-shiur").find(".dow, .date").addClass('hidden')
        $(".#{@chag()}.shema").find(".dow, .date").removeClass('hidden')
    if @hebrew_date.isRoshHashana()
      if @hebrew_date.isShabbat()
        $(".#{@chag()}.afternoon-shiur").find(".dow, .date").removeClass("hidden")
      else
        $(".#{@chag()}.shofar").removeClass("hidden").find(".time").html(time_format(@today().hour(10).minute(30)))
        $(".#{@chag()}.tashlich").removeClass("hidden").find(".time").html("After מִנְחָה")
    if @hebrew_date.isSukkot() && @hebrew_date.is1stDayOfYomTob()
      $(".#{@chag()}.afternoon-shiur").find(".dow, .date").attr("rowspan", if @hebrew_date.isShabbat() then 4 else 2)
      $(".#{@chag()}").find(".hadlakat-nerot").removeClass("hidden")
    if @hebrew_date.isErebHoshanaRaba()
      $(".#{@chag()}.tiqun-leil-hoshana-raba").removeClass('hidden').find('.time').html(@today().hour(0).minute(0).format('h:mm A'))
    if @hebrew_date.is1stDayOfPesach()
      if @shema_is_before_9_am()
        $(".#{@chag()}.shema").find(".dow, .date").attr("rowspan", if @hebrew_date.isShabbat() then 7 else 4)
      else if @hebrew_date.isShabbat()
        $(".#{@chag()}.seudat-shelishit").find(".dow, .date").removeClass('hidden').attr("rowspan", 6)
      else
        $(".#{@chag()}.afternoon-shiur").find(".dow, .date").removeClass('hidden').attr("rowspan", 3)
    if @hebrew_date.is7thDayOfPesach()
      if @hebrew_date.isShabbat()
        $(".#{@chag()}.seudat-shelishit").find(".dow, .date").removeClass('hidden').attr("rowspan", 5)
      else
        $(".#{@chag()}.afternoon-shiur").find(".dow, .date").removeClass('hidden').attr("rowspan", 2)
    if @hebrew_date.is8thDayOfPesach() || (@hebrew_date.is2ndDayOfYomTob() && @hebrew_date.isShabuot())
      $(".#{@chag()}.afternoon-shiur").find(".dow, .date").attr("rowspan", if @hebrew_date.isShabbat() then 4 else 2)
    @afternoon_shiur()
    @rabbenu_tam_schedule() if @hebrew_date.isShabbat() || (@hebrew_date.is2ndDayOfYomTob() && !@hebrew_date.isErebShabbat())
    if @hebrew_date.isShabbat()
      $(".#{@chag()}.seudat-shelishit").removeClass('hidden').find(".time").html(time_format(@seudat_shelishit_time()))
      $(".#{@chag()}.seudat-shelishit .at_home").removeClass('hidden') if @tonight_is_yom_tob()
      if @hebrew_date.isEreb9Ab()
        $(".#{@chag()} .ereb-9-ab").removeClass('hidden')
        $(".#{@chag()} .not-ereb-9-ab").addClass('hidden')
      if @hebrew_date.isShabbatMevarechim()
        nextMonth = new HachrazatRoshChodesh(@hebrew_date)
        $(".#{@chag()}.molad").removeClass('hidden').find('td').html("#{nextMonth.moladAnnouncement()}<br>#{nextMonth.sephardicAnnouncement()}")
      $(".#{@chag()}.molad").removeClass('hidden').find('td').html("#{(new HachrazatTaanit(@hebrew_date)).announcement()}") if @hebrew_date.isHachrazatTaanit()
  yom_kippur_schedule: ->
    @set_date()
    $(".#{@chag()}.sunset .time").html(time_format(@sunset))
    $(".#{@chag()}.neilah .time").html(time_format(minutes_before_event(@sunset, 55)))
    @rabbenu_tam_schedule()
  mincha_on_ereb_shabbat: -> moment.min(moment(@sunset).subtract(33, 'minutes'), @today().hour(18).minute(30))
  mincha: -> @_mincha ?= switch
    when @hebrew_date.isErebRoshHashana() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 55 else 45)
    when @hebrew_date.isRoshHashana() then minutes_before_event(@sunset, @mincha_minutes_before_sunset_on_rosh_hashana())
    when @hebrew_date.isErebYomKippur() then @today().hour(15).minute(30)
    when @hebrew_date.isYomKippur() then minutes_before_event(@sunset, 195)
    when @hebrew_date.isTaanit() then minutes_before_event(@sunset, @mincha_minutes_before_sunset_on_taanit())
    when @hebrew_date.isEreb9Ab() && !@hebrew_date.isShabbat() then minutes_before_event(@sunset, 55)
    when @tonight_is_yom_tob() && @hebrew_date.isShabbat() then minutes_before_event(@sunset, 23)
    when @hebrew_date.is6thDayOfPesach() then @today().hour(18).minute(30)
    when @hebrew_date.isShabbat() then @mincha_on_shabbat()
    when @yom_tob_that_we_can_pray_at_plag() then (if @hebrew_date.isErebShabbat() then @mincha_on_ereb_shabbat() else minutes_before_event(@plag(), 30))
    when @hebrew_date.isYomTob() && !@yom_tob_that_we_can_pray_at_plag() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 40 else 25)
    when @hebrew_date.isErebYomTob() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 33 else  25)
    when @hebrew_date.isErebShabbat() then @mincha_on_ereb_shabbat()
    else recent_hadlakat_nerot
  arbit: -> @_arbit ?= switch
    when @hebrew_date.isErebYomKippur() then minutes_before_event(@sunset, 55)
    when @hebrew_date.isErebShabbat() || (@hebrew_date.isErebYomTob() && !@hebrew_date.isShabbat()) then null
    when @hebrew_date.isYomKippur() || (@hebrew_date.isShabbat() && !@tonight_is_yom_tob()) then @arbit_on_mosaei_shabbat()
    when @has_hadlakat_nerot_after_set_hakochabim() then (if (@yom_tob_that_we_can_pray_at_plag() && !@hebrew_date.isShabbat()) then @plag() else @set_hakochabim_geonim())
    when @hebrew_date.is2ndDayOfYomTob() && !@hebrew_date.isErebShabbat() then minutes_before_event(@zmanim.set_hakochabim, 10)
    else @sunset
  hadlakat_nerot: -> if @has_hadlakat_nerot_after_set_hakochabim() then moment(@zmanim.set_hakochabim) else moment(@sunset).subtract(19, 'minutes')
  has_hadlakat_nerot_after_set_hakochabim: -> (@hebrew_date.isErebYomTob() && @hebrew_date.isShabbat()) || (@hebrew_date.is1stDayOfYomTob() && !@hebrew_date.isErebShabbat())
  has_hadlakat_nerot_before_sunset: -> @hebrew_date.isErebShabbat() || @hebrew_date.isErebYomKippur() || @hebrew_date.isErebYomTob()
  hadlakat_nerot_text: ->
    if @yom_tob_that_we_can_pray_at_plag() && !@hebrew_date.isErebShabbat() && !@hebrew_date.isShabbat()
      "Before Kiddush<br><b>Eat from all cooked<br>foods before #{time_format(@sunset)}</b>"
    else if @has_hadlakat_nerot_after_set_hakochabim()
      "After #{if @hebrew_date.isShabbat() then 'שַׁבָּת ends' else time_format(@hadlakat_nerot())}"
    else time_format(@hadlakat_nerot())
  sedra: -> "#{if @hebrew_date.isRegel() || @hebrew_date.isYomKippur() || @hebrew_date.isYomTob() then "" else "שַׁבַּת פְּרָשָׁת"} #{@hebrew_date.sedra().replace(/-/g, ' - ')}"
  tiqun_leil_hoshana_raba_schedule: ->
    $(".#{@chag()}").removeClass("hidden").find('.time').html(@today().hour(0).minute(0).format('h:mm A'))
    @set_date()
  announcement: -> @_announcement ?= (
    a = window.announcements[@hebrew_date.getHebrewYear().getYearFromCreation()]
    a = a[@hebrew_date.weekOfYear()] if a?
    )

window.mincha_and_arbit = (day_iterator) ->
  schedule = new Schedule(day_iterator)
  recent_hadlakat_nerot = schedule.hadlakat_nerot() if schedule.has_hadlakat_nerot_before_sunset()
  if schedule.hebrew_date.isErebShabbat() || schedule.hebrew_date.isErebYomKippur() || schedule.hebrew_date.isErebYomTob()
    schedule.hadlakat_nerot_schedule()
  if schedule.hebrew_date.isYomKippur()
    schedule.yom_kippur_schedule()
  else if schedule.hebrew_date.isShabbat() || schedule.hebrew_date.isYomTob()
    schedule.shabbat_schedule()
  else if schedule.hebrew_date.isTaanit() || schedule.hebrew_date.isEreb9Ab() || schedule.hebrew_date.isPurim()
    schedule.taanit_schedule()
  if schedule.hebrew_date.isShabbat()
    $('.sedra').html(schedule.sedra())
    $(".announcement.jumbotron").removeClass('hidden').html(schedule.announcement()) if schedule.announcement()?
  else if schedule.hebrew_date.isErebHoshanaRaba()
    schedule.tiqun_leil_hoshana_raba_schedule()
  mincha: time_format(schedule.mincha()), arbit: time_format(schedule.arbit())
