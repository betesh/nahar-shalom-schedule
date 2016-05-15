//= require ../vendor/hebrewDate
//= require ../site/helpers

class Shaharit
  constructor: (hebrewDate, sunrise, sofZmanKeriatShema) ->
    # TODO: sofZmanKeriatShema is not currently used
    [@hebrewDate, @sunrise, @sofZmanKeriatShema] = [hebrewDate, sunrise, sofZmanKeriatShema]
  noMelacha: -> @hebrewDate.isShabbat() || @hebrewDate.isYomTob() || @hebrewDate.isYomKippur()
  hasSelihot: -> (@hebrewDate.is10DaysOfTeshuba() || @hebrewDate.inElul()) && !@noMelacha() && !@hebrewDate.isRoshChodesh()
  selihotMinutes: -> @_selihotMinutes ?= switch
      when @hebrewDate.is10DaysOfTeshuba() then 56
      when @hebrewDate.inElul() then 50
  korbanotMinutes: -> @_korbanotMinutes ?= if @noMelacha() then 15 else 16
  korbanotVatikinMinutes: -> @korbanotMinutes()
  hoduVatikinMinutes: -> @_hoduVatikinMinutes ?= switch
    when @hebrewDate.isYomKippur() then 42
    when @hebrewDate.isShabuot() && @hebrewDate.is1stDayOfYomTob() then 38
    when @hebrewDate.isYomTob() then 29
    when @hebrewDate.isShabbat() then 27
    when @hebrewDate.isMoed() then 13
    else 11.5
  nishmatVatikinMinutes: -> @_nishmatVatikinMinutes ?= if @noMelacha() then 4 else null
  yishtabachVatikinMinutes: -> @_yishtabachVatikinMinutes ?= if @noMelacha() then 13 else 8.5
  korbanotVatikin: -> @_korbanotVatikin ?= moment(@hoduVatikin()).subtract(@korbanotVatikinMinutes(), 'minutes') if @hoduVatikin()?
  hoduVatikin: -> @_hoduVatikin ?= moment(@yishtabachVatikin()).subtract(@hoduVatikinMinutes(), 'minutes') if @yishtabachVatikin()?
  nishmatVatikin: -> @_nishmatVatikin ?= moment(@yishtabachVatikin()).subtract(@nishmatVatikinMinutes(), 'minutes') if @yishtabachVatikin()? && @nishmatVatikinMinutes()?
  yishtabachVatikin: ->  @_yishtabachVatikin ?= moment(@amidahVatikin()).subtract(@yishtabachVatikinMinutes(), 'minutes') if @amidahVatikin()?
  amidahVatikin: ->  @_amidahVatikin ?= @sunrise
  korbanotLate: -> @_korbanotLate ?= moment(@hoduLate()).subtract(@korbanotMinutes(), 'minutes') if @hoduLate()?
  hoduLateOnShabbat: -> @_hoduLateOnShabbat ?= if moment(@hebrewDate.gregorianDate).isBefore(moment("2016-03-13", "YYYY-MM-DD"))
      moment(@hebrewDate.gregorianDate).hours(8).minutes(0).seconds(0)
    else
      moment(@hebrewDate.gregorianDate).hours(8).minutes(30).seconds(0)
  hoduLate: -> @_hoduLate ?= switch
    when @hebrewDate.isYomKippur() then moment(@hebrewDate.gregorianDate).hours(7).minutes(15).seconds(0)
    when @hebrewDate.is1stDayOfPesach() || @hebrewDate.is2ndDayOfPesach() then moment(@hebrewDate.gregorianDate).hours(9).minutes(0).seconds(0)
    when @hebrewDate.isShabuot() && @hebrewDate.is1stDayOfYomTob() then null
    when @hebrewDate.isYomTob() then moment(@hebrewDate.gregorianDate).hours(8).minutes(0).seconds(0)
    when @hebrewDate.isShabbat() then @hoduLateOnShabbat()
    else null
  selihot: -> @_selihot ?= if @hasSelihot() then moment(@korbanotVatikin()).subtract(@selihotMinutes(), 'minutes').seconds(0) else null
  korbanot: -> if @korbanotLate()? then [@korbanotVatikin().seconds(0), @korbanotLate().seconds(0)] else [@korbanotVatikin().seconds(0)]
  hodu: -> if @hoduLate()? then [@hoduVatikin().seconds(0), @hoduLate().seconds(0)] else [@hoduVatikin().seconds(0)]
  nishmat: -> @nishmatVatikin().seconds(0) if @nishmatVatikin()?
  yishtabach: -> @yishtabachVatikin().seconds(0)
  amidah: -> @amidahVatikin()

(exports ? this).Shaharit = Shaharit
