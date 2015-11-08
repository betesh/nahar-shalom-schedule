class Vatikin
  constructor: (gregorianDate, hebrewDate) ->
    @today = moment(gregorianDate)
    @sunrise = new Sunrise(gregorianDate).get()
    @day = moment(gregorianDate).format('dddd')
    @schedule = switch
      when !@sunrise? then Vatikin.NULL
      when hebrewDate.isYomKippur() then Vatikin.YOM_KIPPUR
      when hebrewDate.isYomTob() || hebrewDate.isShabbat() then Vatikin.YOM_TOB
      when hebrewDate.isMoed() then Vatikin.HOL_HAMOED
      when hebrewDate.is10DaysOfTeshuba() then Vatikin.ASERET_YEMEI_TESHUBA
      when hebrewDate.inElul() && !hebrewDate.isRoshChodesh() then Vatikin.ELUL
      else Vatikin.WEEKDAY
  updateDOM: ->
    $(".#{@day} .amidah").html(if @sunrise? then @sunrise.format("h:mm:ss") else "??")
    for step in ['yishtabach', 'hodu', 'korbanot', 'selihot']
      $(".#{@day} .#{step}").html(if @sunrise? && @schedule[step] then @sunrise.subtract(@schedule[step], 'minutes').format("h:mm") else "")
    $(".#{@day} .selihot").removeClass('hidden') if @schedule.selihot

(->
  @NULL = { }
  @YOM_KIPPUR = { korbanot: 15, hodu: 36, yishtabach: 17 }
  @YOM_TOB = { korbanot: 15, hodu: 26, yishtabach: 17 }
  @HOL_HAMOED = { korbanot: 16, hodu: 13, yishtabach: 8.5 }
  @ASERET_YEMEI_TESHUBA = { selihot: 56, korbanot: 16, hodu: 11.5, yishtabach: 8.5 }
  @ELUL = { selihot: 50, korbanot: 16, hodu: 11.5, yishtabach: 8.5 }
  @WEEKDAY = { korbanot: 16, hodu: 11.5, yishtabach: 8.5 }
).call(Vatikin)

window.Vatikin = Vatikin
