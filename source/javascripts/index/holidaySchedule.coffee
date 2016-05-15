//= require ../site/zmanim
//= require ../site/hebrewDateExtensions
//= require ../site/helpers
//= require ./mincha
//= require ./hachrazatTaanit

time_format = (time) -> time.format('h:mm') if time?
minutes_before_event = (event, minutes)-> NaharShalomScheduleHelpers.roundedToNearest5Minutes(moment(event).subtract(minutes, 'minutes'))

class HolidaySchedule
  constructor: (gregorianDate, hebrewDate, zmanim) ->
    [@gregorianDate, @hebrew_date, @zmanim] = [gregorianDate, hebrewDate, zmanim]
    @sunset = @zmanim.sunset().subtract(30, 'second')
  today: -> moment(@sunset)
  shema_is_before_9_am: -> @zmanim.sofZmanKeriatShema().isBefore(@today().hour(if (@hebrew_date.is1stDayOfPesach() || @hebrew_date.is2ndDayOfPesach()) then 10 else 9).minute(0))
  afternoon_shiur_time: ->
    if @hebrew_date.isErebShabuot()
      minutes_before_event(@sunset, 45)
    else
      moment(@mincha()).subtract(1, 'hour')
  afternoon_shiur: -> $(".#{@chag()}.afternoon-shiur").removeClass("hidden").find(".time").html(time_format(@afternoon_shiur_time()))
  set_hakochabim: -> time_format(@zmanim.setHaKochabim3Stars())
  rabbenu_tam: -> time_format(moment(@sunset).add(73, 'minute'))
  set_hakochabim_geonim: -> @zmanim.setHaKochabimGeonim()
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
      else throw "This should never happen!"
    rishon_or_sheni = switch
      when ((@hebrew_date.isErebYomTob() || @hebrew_date.isEreb9Ab()) && !@hebrew_date.isShabbat()) || @hebrew_date.isErebYomKippur() || (@hebrew_date.isErebShabbat() && !@hebrew_date.isPurim() && !@hebrew_date.isYomTob()) then '.eve'
      when @hebrew_date.is1stDayOfYomTob() then '.first'
      when @hebrew_date.is2ndDayOfYomTob() then '.second'
      when @hebrew_date.isShabbat() || @hebrew_date.isYomKippur() || @hebrew_date.isTaanit() then '.day'
      when @hebrew_date.isPurim() then  '.purim-row'
      when @hebrew_date.isErebHoshanaRaba() then '.tiqun-leil-hoshana-raba'
      else throw "This should never happen!"
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
    half_hour_after_rabbenu_tam = NaharShalomScheduleHelpers.roundedToNearest5Minutes(moment(@sunset).add(101, 'minute'))
    unless @hebrew_date.isShabbatZachor() && 13 == @hebrew_date.dayOfMonth
      if half_hour_after_rabbenu_tam.isBefore(@today().hour(20).minute(16))
        $(".#{@chag()}.abot-ubanim").removeClass('hidden').find(".time").html(time_format(half_hour_after_rabbenu_tam))
  chatzot: -> time_format(@zmanim.chatzot())
  taanit_schedule: ->
    @set_date()
    name = switch
      when @hebrew_date.is17Tamuz() then "Tamuz17"
      when @hebrew_date.is10Tevet() then "Tebet10"
      when @hebrew_date.isFastOfGedaliah() then "FastOfGedaliah"
      when @hebrew_date.isTaanitEster() then (if 13 == @hebrew_date.dayOfMonth then "TaanitEsterAndPurim" else "TaanitEster")
      when @hebrew_date.isPurim() then (if 0 == @gregorianDate.getDay() then "PurimOnly" else null)
      when @hebrew_date.isEreb9Ab() || @hebrew_date.is9Ab() then null
      else throw "This should never happen!"
    $(".taanit th .#{name}").removeClass("hidden") if name?
    if @hebrew_date.isPurim()
      $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html("#{minutes_before_event(@zmanim.sunrise(), -20).format('h:mm A')} <strong>and</strong> #{@today().hour(9).minute(30).format('h:mm A')}")
      $(".#{@chag()}.megilla").find(".dow, .date").attr("rowspan", if @hebrew_date.isErebShabbat() then 2 else 1)
      return
    fast_begins_row = $(".#{@chag()}.fast-begins").removeClass('hidden')
    if @hebrew_date.isEreb9Ab()
      fast_begins_row.find(".time").html(@sunset.format('h:mm A'))
    else if @hebrew_date.is9Ab()
      $(".#{@chag()}.chatzot .time").html(@chatzot())
      $(".#{@chag()}.chatzot").find(".dow, .date").attr("rowspan", if 0 == @gregorianDate.getDay() then 3 else 2)
      $(".#{@chag()}.habdala").removeClass("hidden") if 0 == @gregorianDate.getDay()
    else
      fast_begins_row.find(".dow, .date").attr("rowspan", if @hebrew_date.isTaanitEster() then (if 13 == @hebrew_date.dayOfMonth then 4 else 3) else 2)
      fast_begins_row.find(".time").html(@zmanim.magenAbrahamDawn().format('h:mm A'))
    fast_ends = @set_hakochabim_geonim()
    $(".#{@chag()}.fast-ends").removeClass('hidden').find(".time").html(fast_ends.format('h:mm A'))
    if @hebrew_date.isTaanitEster()
      $(".#{@chag()}.mahasit-hashekel").removeClass('hidden')
      if 13 == @hebrew_date.dayOfMonth
        $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html(minutes_before_event(fast_ends, -7).format('h:mm A'))
  seudat_shelishit_time: -> if @hebrew_date.is1stDayOfYomTob() then @zmanim.samuchLeminchaKetana() else @sunset
  shabbat_schedule: ->
    @set_date()
    @hadlakat_nerot_schedule() if @hebrew_date.tonightIsYomTob()
    if @hebrew_date.isShabbatZachor()
      zachor1 = minutes_before_event(@zmanim.sunrise(), -35).format('h:mm A')
      zachor2 = @today().hour(9).minute(45).format('h:mm A')
      zachor3 = "#{@today().hour(14).minute(30).format('h:mm A')} upon request"
      $(".#{@chag()}.zachor").removeClass('hidden').find('.time').html("#{zachor1} <strong>and</strong> #{zachor2}<br>(#{zachor3})")
      $(".#{@chag()}.afternoon-shiur").find(".dow, .date").addClass('hidden')
      $(".#{@chag()}.megilla").removeClass('hidden').find(".time").html(minutes_before_event(@sunset, -100).format('h:mm A')) if 13 == @hebrew_date.dayOfMonth
      $(".#{@chag()}.zachor").find(".dow, .date").removeClass('hidden') unless @shema_is_before_9_am()
    if @shema_is_before_9_am()
      $(".#{@chag()}.shema").removeClass('hidden').find('.time').html(time_format(@zmanim.sofZmanKeriatShema()))
      $(".#{@chag()}.shema").removeClass('hidden').find(".dow, .date").attr("rowspan", if @hebrew_date.isShabbatZachor() then 6 else 5)
      $(".#{@chag()}.afternoon-shiur").find(".dow, .date").addClass('hidden')
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
      if @hebrew_date.isEreb9Ab() || @hebrew_date.isErebShabuot()
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
  mincha: -> @_mincha ?= (new Mincha(@hebrew_date, @zmanim.plag(), @sunset)).time()
  hadlakat_nerot: -> if @hebrew_date.hasHadlakatNerotAfterSetHaKochabim() then @zmanim.setHaKochabim3Stars() else moment(@sunset).subtract(19, 'minutes')
  has_hadlakat_nerot_before_sunset: -> @hebrew_date.isErebShabbat() || @hebrew_date.isErebYomKippur() || @hebrew_date.isErebYomTob()
  hadlakat_nerot_text: ->
    if @hebrew_date.yomYobThatWePrayAtPlag() && !@hebrew_date.isErebShabbat() && !@hebrew_date.isShabbat()
      "Before Kiddush<br><b>Eat from all cooked<br>foods before #{time_format(@sunset)}</b>"
    else if @hebrew_date.hasHadlakatNerotAfterSetHaKochabim()
      "After #{if @hebrew_date.isShabbat() then 'שַׁבָּת ends' else time_format(@hadlakat_nerot())}"
    else time_format(@hadlakat_nerot())
  tiqun_leil_hoshana_raba_schedule: ->
    $(".#{@chag()}").removeClass("hidden").find('.time').html(@today().hour(0).minute(0).format('h:mm A'))
    @set_date()

(exports ? this).HolidaySchedule = HolidaySchedule
