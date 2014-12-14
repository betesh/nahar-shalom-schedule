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
HebrewDate.prototype.is2ndDayOfYomTob = -> @is2ndDayOfPesach() || @monthAndRangeAre('SIVAN', [7]) || @monthAndRangeAre('TISHRI', [2,16,23])

time_format = (time) -> time.format('h:mm') if time?
round_down_to_5_minutes = (time) -> time.subtract(time.minute() % 5, 'minutes')
minutes_before_event = (event, minutes)-> round_down_to_5_minutes(moment(event).subtract(minutes, 'minutes'))
recent_hadlakat_nerot = null;

portion_of_day = (zmanim, ratio) ->
  sunrise = moment(zmanim.sunrise)
  sunrise.add(moment(zmanim.sunset).diff(sunrise, 'minutes') * ratio, 'minutes')

begin_seudat_shelishit_samuch_lemincha_ketana = (hebrew_date, zmanim) -> # This code is no longer called from anywhere
  start_eating_at = samuch_lemincha_ketana(zmanim)
  $('.shabbat .seudat-shelishit .time').html(time_format(start_eating_at)) if (hebrew_date.isErebYomTob() || hebrew_date.is1stDayOfYomTob()) && hebrew_date.isShabbat()
  start_eating_at

show_mosaei_yom_tob = (date, zmanim) -> # This code is no longer called from anywhere
  $('.mosaei-yom-tob').removeClass('hidden').find('.date').html(moment.weekdays()[date.weekday()])
  $('.yom-tob-ends').html(set_hakochabim(zmanim))

class Schedule
  constructor: (day_iterator) ->
    @hebrew_date = new HebrewDate(day_iterator.toDate())
    @zmanim = SunCalc.getTimes(moment(day_iterator).toDate().setHours(12), window.config.latitude, window.config.longitude)
    @sunset = moment(@zmanim.sunset).subtract(30, 'second')
  today: -> moment(@sunset)
  last_time_for_shema: -> @_last_time_for_shema ?= moment(@zmanim.magen_abraham_dawn).add((@zmanim.magen_abraham_dusk - @zmanim.magen_abraham_dawn) / 4000 - 120, 'seconds')
  shema_is_before_9_am: -> @last_time_for_shema().isBefore(@today().hour(9).minute(0))
  mincha_minutes_before_sunset_on_shabbat: -> if @hebrew_date.isEreb9Ab() then 100 else 45
  mincha_minutes_before_sunset_on_rosh_hashana: -> if @hebrew_date.is1stDayOfYomTob() || @hebrew_date.isErebShabbat() then 60 else 40
  mincha_minutes_before_sunset_on_taanit: -> switch
    when @hebrew_date.is9Ab() || @hebrew_date.isErebShabbat() then 45
    when @hebrew_date.isTaanitEster() then 35
    else 30
  arbit_minutes_after_set_hakochabim_on_mosaei_shabbat: -> if @hebrew_date.isEreb9Ab() then 55 else 10
  mincha_on_shabbat: -> minutes_before_event(@sunset, @mincha_minutes_before_sunset_on_shabbat())
  arbit_on_mosaei_shabbat: -> moment(@zmanim.set_hakochabim).add(@arbit_minutes_after_set_hakochabim_on_mosaei_shabbat(), 'minutes')
  afternoon_shiur: -> $(".#{@chag()}.afternoon-shiur .time").html(time_format(moment(@mincha()).subtract(1, 'hour')))
  samuch_lemincha_ketana: -> portion_of_day(@zmanim, 0.75)
  plag: -> moment(@_plag ?= portion_of_day(@zmanim, 43.0/48.0))
  plag_is_before_615: -> @plag().isBefore(@today().hour(18).minute(15))
  set_hakochabim: -> time_format(moment(@zmanim.set_hakochabim))
  rabbenu_tam: -> time_format(moment(@sunset).add(73, 'minute'))
  chag: -> @_chag ?= (
    name_of_chag = switch
      when @hebrew_date.isErebPesach() || @hebrew_date.is1stDayOfPesach() || @hebrew_date.is2ndDayOfPesach() then 'pesach-first-days'
      when @hebrew_date.is6thDayOfPesach() || @hebrew_date.is7thDayOfPesach() || @hebrew_date.is8thDayOfPesach() then 'pesach-last-days'
      when @hebrew_date.isErebShabuot() || @hebrew_date.isShabuot() then 'shabuot'
      when @hebrew_date.isErebRoshHashana() || @hebrew_date.isRoshHashana() then 'rosh-hashana'
      when @hebrew_date.isErebSukkot() || (@hebrew_date.isSukkot() && !@hebrew_date.isHoshanaRaba() && !@hebrew_date.isSheminiAseret()) then 'sukkot-first-days'
      when @hebrew_date.isHoshanaRaba() || @hebrew_date.isSheminiAseret() then 'sukkot-last-days'
      when @hebrew_date.isErebYomKippur() || @hebrew_date.isYomKippur() then 'yom-kippur'
      when @hebrew_date.isErebShabbat() || @hebrew_date.isShabbat() then 'shabbat'
      when @hebrew_date.isTaanit() && !@hebrew_date.is9Ab() then 'taanit'
      when (@hebrew_date.is9Ab() || @hebrew_date.isEreb9Ab()) && !@hebrew_date.isShabbat() then 'chabob'
      else console.warn "This should never happen!"
    rishon_or_sheni = switch
      when @hebrew_date.isErebYomTob() || @hebrew_date.isErebYomKippur() || @hebrew_date.isErebShabbat() || (@hebrew_date.isEreb9Ab() && !@hebrew_date.isShabbat()) then '.eve'
      when @hebrew_date.is1stDayOfYomTob() then '.first'
      when @hebrew_date.is2ndDayOfYomTob() then '.second'
      when @hebrew_date.isShabbat() || @hebrew_date.isYomKippur() || @hebrew_date.isTaanit() then '.day'
      else console.warn "This should never happen!"
    "#{name_of_chag} #{rishon_or_sheni}")
  set_date: ->
    $(".#{@chag().split('.')[0]}").not('.event').removeClass('hidden')
    $(".#{@chag()} .date").html(@sunset.format('D MMM'))
    $(".#{@chag()} .dow").html(if @hebrew_date.isShabbat() then "שַׁבָּת" else @sunset.format('dddd'))
  hadlakat_nerot_schedule: ->
    @set_date()
    $(".#{@chag()}.hadlakat-nerot .time").html(@hadlakat_nerot_text())
  rabbenu_tam_schedule: ->
    $(".#{@chag()}.ends .time").html(@set_hakochabim())
    $(".#{@chag()}.rabbenu-tam .time").html(@rabbenu_tam())
    half_hour_after_rabbenu_tam = round_down_to_5_minutes(moment(@sunset).add(101, 'minute'))
    $(".#{@chag()}.abot-ubanim").removeClass('hidden').find(".time").html(time_format(half_hour_after_rabbenu_tam)) if half_hour_after_rabbenu_tam.isBefore(@today().hour(20).minute(16))
  chatzot: -> time_format(moment(@zmanim.solarNoon))
  taanit_schedule: ->
    @set_date()
    if @hebrew_date.isEreb9Ab()
      $(".#{@chag()}.fast-begins").removeClass('hidden').find(".time").html(@sunset.format('h:mm A'))
    else if @hebrew_date.is9Ab()
      $(".#{@chag()}.chatzot .time").html(@chatzot())
    else
      $(".#{@chag()}.fast-begins").removeClass('hidden').find(".time").html(moment(@zmanim.magen_abraham_dawn).format('h:mm A'))
    fast_ends = moment(@sunset).add(parseInt((@zmanim.magen_abraham_dusk - @zmanim.magen_abraham_dawn) * 3 / 160000 + 60), 'seconds') # 13.5 dakot zemaniyot after sunset, rounded to end of minute
    $(".#{@chag()}.fast-ends .time").html(fast_ends.format('h:mm A'))
  shabbat_schedule: ->
    @set_date()
    if @shema_is_before_9_am()
      $(".#{@chag()}.shema").removeClass('hidden').find('.time').html(time_format(@last_time_for_shema()))
      $(".#{@chag()}.afternoon-shiur td[rowspan=4]").addClass('hidden')
    $(".#{@chag()}.seudat-shelishit .time").html(time_format(@sunset))
    if @hebrew_date.isEreb9Ab()
      $(".#{@chag()} .ereb-9-ab").removeClass('hidden')
      $(".#{@chag()} .not-ereb-9-ab").addClass('hidden')
    @rabbenu_tam_schedule()
    if @hebrew_date.isShabbatMevarechim()
      nextMonth = new HachrazatRoshChodesh(@hebrew_date)
      $(".#{@chag()}.molad").removeClass('hidden').find('td').html("#{nextMonth.moladAnnouncement()}<br>#{nextMonth.sephardicAnnouncement()}")
    $(".#{@chag()}.molad").removeClass('hidden').find('td').html("#{(new HachrazatTaanit(@hebrew_date)).announcement()}") if @hebrew_date.isHachrazatTaanit()
  yom_kippur_schedule: ->
    @set_date()
    $(".#{@chag()}.sunset .time").html(time_format(@sunset))
    $(".#{@chag()}.neilah .time").html(time_format(minutes_before_event(@sunset, 55)))
    @rabbenu_tam_schedule()
  mincha: -> @_mincha ?= switch
    when @hebrew_date.isErebRoshHashana() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 55 else 45)
    when @hebrew_date.isRoshHashana() then minutes_before_event((if @hebrew_date.isShabbat() then @samuch_lemincha_ketana() else @sunset), (if @hebrew_date.isShabbat() then 90 else @mincha_minutes_before_sunset_on_rosh_hashana()))
    when @hebrew_date.isErebYomKippur() then @today().hour(15).minute(30)
    when @hebrew_date.isYomKippur() then minutes_before_event(@sunset, 195)
    when @hebrew_date.isTaanit() then minutes_before_event(@sunset, @mincha_minutes_before_sunset_on_taanit())
    when @hebrew_date.isEreb9Ab() && !@hebrew_date.isShabbat() then minutes_before_event(@sunset, 55)
    when (@hebrew_date.isErebYomTob() || @hebrew_date.is1stDayOfYomTob()) && @hebrew_date.isShabbat() then minutes_before_event(@samuch_lemincha_ketana(), 60)
    when @hebrew_date.is6thDayOfPesach() then @today().hour(18).minute(30)
    when @hebrew_date.isShabbat() then @mincha_on_shabbat()
    when @hebrew_date.is7thDayOfPesach() || @hebrew_date.is1stDayOfShabuot() then minutes_before_event(@plag(), 30)
    when @hebrew_date.isYomTob() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 40 else 25)
    when @hebrew_date.isErebYomTob() then minutes_before_event(@sunset, if @hebrew_date.isErebShabbat() then 33 else  25)
    when @hebrew_date.isErebShabbat() then moment.min(moment(@sunset).subtract(33, 'minutes'), @today().hour(18).minute(30))
    else recent_hadlakat_nerot
  arbit: -> @_arbit ?= switch
    when @hebrew_date.isErebYomKippur() then minutes_before_event(@sunset, 55)
    when @hebrew_date.isErebShabbat() || ((@hebrew_date.isErebYomTob() || @hebrew_date.is1stDayOfYomTob()) && !@hebrew_date.isShabbat()) then null
    when @hebrew_date.isYomKippur() || (@hebrew_date.isShabbat() && !@hebrew_date.isErebYomTob() && !@hebrew_date.is1stDayOfYomTob()) then @arbit_on_mosaei_shabbat()
    when @hebrew_date.is7thDayOfPesach() || @hebrew_date.is1stDayOfShabuot() then @plag()
    when @hebrew_date.is2ndDayOfYomTob() && !@hebrew_date.isErebShabbat() then minutes_before_event(@zmanim.set_hakochabim, 10)
    else @sunset
  hadlakat_nerot: -> if @has_hadlakat_nerot_after_set_hakochabim() then @zmanim.set_hakochabim else moment(@sunset).subtract(19, 'minutes')
  has_hadlakat_nerot_after_set_hakochabim: -> (@hebrew_date.isErebYomTob() && @hebrew_date.isShabbat()) || (@hebrew_date.is1stDayOfYomTob() && !@hebrew_date.isErebShabbat())
  has_hadlakat_nerot_before_sunset: -> @hebrew_date.isErebShabbat() || @hebrew_date.isErebYomKippur() || @hebrew_date.isErebYomTob()
  hadlakat_nerot_text: ->
    if (@hebrew_date.is7thDayOfPesach() || @hebrew_date.is1stDayOfShabuot()) && !@hebrew_date.isErebShabbat() && !@hebrew_date.isShabbat()
      "Before Kiddush<br><b>Eat from all cooked<br>foods before #{time_format(@sunset)}</b>"
    else if @has_hadlakat_nerot_after_set_hakochabim()
      "After #{if @hebrew_date.isShabbat() then 'שַׁבָּת ends' else time_format(@hadlakat_nerot())}"
    else time_format(@hadlakat_nerot())
  sedra: -> "#{if @hebrew_date.isRegel() || @hebrew_date.isYomKippur() || @hebrew_date.isYomTob() then "" else "שַׁבַּת פְּרָשָׁת"} #{@hebrew_date.sedra().replace(/-/g, ' - ')}"

window.mincha_and_arbit = (day_iterator) ->
  schedule = new Schedule(day_iterator)
  recent_hadlakat_nerot = schedule.hadlakat_nerot() if schedule.has_hadlakat_nerot_before_sunset()
  schedule.hadlakat_nerot_schedule() if schedule.hebrew_date.isErebShabbat() || schedule.hebrew_date.isErebYomKippur()
  if schedule.hebrew_date.isYomKippur()
    schedule.yom_kippur_schedule()
  else
    schedule.shabbat_schedule() if schedule.hebrew_date.isShabbat()
    schedule.taanit_schedule() if schedule.hebrew_date.isTaanit() || schedule.hebrew_date.isEreb9Ab()
    schedule.afternoon_shiur() if schedule.hebrew_date.isShabbat() || schedule.hebrew_date.isYomTob()
  $('.sedra').html(schedule.sedra()) if schedule.hebrew_date.isShabbat()
  mincha: time_format(schedule.mincha()), arbit: time_format(schedule.arbit())
