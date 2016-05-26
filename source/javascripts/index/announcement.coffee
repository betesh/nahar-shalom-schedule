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
        # TODO: This could be more accurate if we generate the burn announcement using Friday's time instead of Saturday's
      else
        "#{@stopEating()}<br>#{@burn()}"

class Announcement
  constructor: (hebrewDate, zmanim) ->
    [@hebrewDate, @zmanim] = [hebrewDate, zmanim]
  announcement: -> @_announcement ?= (
    announcements = []
    announcement1 = @configuredAnnouncement()
    announcement2 = @generatedAnnouncement()
    announcements.push(announcement1) if announcement1?
    announcements.push(announcement2) if announcement2?
    announcements
    )
  generatedAnnouncement: ->
    if @hebrewDate.isErebPesach()
      (new ErebPesachAnnouncement(@hebrewDate, @zmanim)).announcement()
    else if @hebrewDate.isEreb9Ab() && @hebrewDate.isShabbat()
      "Bring your תִּשְׁעָה בְּאָב shoes to shul before שַׁבָּת"
    else if @hebrewDate.isErebShabuot() && @hebrewDate.isShabbat()
      "If starting סְעוּדַת שְׁלִישִׁית after #{@zmanim.samuchLeminchaKetana().format("h:mm A")}, wash your hands without a בְּרָכָה and eat less than 54 grams of bread.<br><b>There will be סְעוּדַת שְׁלִישִׁית in shul.</b>"
  configuredAnnouncement: ->
    year = @hebrewDate.getHebrewYear().getYearFromCreation()
    week = @hebrewDate.weekOfYear()
    console.log "Looking for announcement for week #{week} of year #{year}"
    window.announcements[year]?[week]

(exports ? this).Announcement = Announcement
