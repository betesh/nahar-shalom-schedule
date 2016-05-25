# TODO: Test this class
//= require ./announcements

class ErebPesachAnnouncement
  constructor: (hebrewDate, zmanim) ->
    [@hebrewDate, @zmanim] = [hebrewDate, zmanim]
  latestTimeToEat: -> @_latestTimeToEat ?= @zmanim.shaaZemaniMagenAbraham(4).format('h:mm A')
  latestTimeToBurn: -> @_latestTimeToBurn ?= @zmanim.shaaZemaniMagenAbraham(5).format('h:mm A')
  stopEating: -> @_stopEating ?= "Stop eating חָמֵץ before #{@latestTimeToEat()}#{if @hebrewDate.isShabbat() then " on שַׁבָּת"  else ""}"
  burn: -> @_burn ?= "Burn חָמֵץ before #{@latestTimeToBurn()}#{if @hebrewDate.isShabbat() then " on Friday" else ""}"
  nullify: -> @_nullify ?= "Make sure no חָמֵץ is in your possesion and say כָּל חֲמִירָא before #{@latestTimeToBurn()} on שַׁבָּת"
  announcement: -> @_announcement ?=if @hebrewDate.isShabbat()
        "#{@burn()}<br>#{@stopEating()}<br>#{@nullify()}"
        # TODO: Need to decide what to do announce about Seudat Shelishit
      else
        "#{@stopEating()}<br>#{@burn()}"

class Announcement
  constructor: (hebrewDate, zmanim) ->
    [@hebrewDate, @zmanim] = [hebrewDate, zmanim]
  announcement: -> @_announcement ?= if @hebrewDate.isErebPesach()
      (new ErebPesachAnnouncement(@hebrewDate, @zmanim)).announcement()
    else if @hebrewDate.isEreb9Ab() && @hebrewDate.isShabbat()
      "Bring your תִּשְׁעָה בְּאָב shoes to shul before שַׁבָּת"
    else if @hebrewDate.isErebShabuot() && @hebrewDate.isShabbat()
      "If starting סְעוּדַת שְׁלִישִׁית after #{@zmanim.samuchLeminchaKetana().format("h:mm A")},wash your hands without a בְּרָכָה and eat less then 54 grams of bread.<br><b>There will be סְעוּדַת שְׁלִישִׁית in shul.</b>"
    else
      a = window.announcements[@hebrewDate.getHebrewYear().getYearFromCreation()]
      a = a[@hebrewDate.weekOfYear()] if a?

(exports ? this).Announcement = Announcement
