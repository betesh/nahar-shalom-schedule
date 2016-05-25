//= require ./hachrazatTaanit
//= require ../site/helpers

minutesBefore = NaharShalomScheduleHelpers.minutesBefore
minutesAfter = NaharShalomScheduleHelpers.minutesAfter
roundedToNearest5Minutes = NaharShalomScheduleHelpers.roundedToNearest5Minutes

dayOfWeek = (gregorianDate, hebrewDate, rows) ->
  dow = if hebrewDate.isShabbat() then "שַׁבָּת" else gregorianDate.format('dddd')
  dow = "#{dow} night" if rows[0]?.tomorrow
  dow

zachorTimes = (shaharit) ->
  zachor1 = roundedToNearest5Minutes(minutesAfter(shaharit.hodu()[0], 80)).format('h:mm A')
  zachor2 = roundedToNearest5Minutes(minutesAfter(shaharit.hodu()[1], 105)).format('h:mm A')
  "#{zachor1} <strong>and</strong> #{zachor2}"

morningMegillaTimes = (gregorianDate, zmanim) ->
  megilla1 = roundedToNearest5Minutes(minutesAfter(zmanim.sunrise(), 20))
  megilla2 = moment(gregorianDate).hour(9).minute(30).second(0)
  "#{megilla1.format('h:mm A')} <strong>and</strong> #{megilla2.format('h:mm A')}"

afternoonShiurimTimes = (hebrewDate, mincha) ->
  minuteList = if hebrewDate.isErebShabuot()
    [90, 60, -65]
  else
    [120, 90, 30]
  (minutesBefore(mincha, minutes).format('h:mm') for minutes in minuteList).join(" / ")

hadlakatNerotTime = (hebrewDate, zmanim) ->
  if hebrewDate.yomYobThatWePrayAtPlag() && !hebrewDate.isErebShabbat() && !hebrewDate.isShabbat()
    "Before Kiddush"
  else if hebrewDate.isShabbat()
    "After שַׁבָּת ends"
  else if hebrewDate.hasHadlakatNerotAfterSetHaKochabim()
    "After #{zmanim.setHaKochabim3Stars().format('h:mm')}"
  else
    zmanim.hadlakatNerot().format('h:mm')

seudat_shelishit_in_shul_description = (hebrewDate) ->
  verb = if hebrewDate.isErebShabuot() || hebrewDate.isEreb9Ab() then "<strong>Finish</strong>" else "Begin"
  "<span class='font13'>#{verb} סְעוּדַת שְׁלִישִׁית before</span>"

rabbenuTamTime = (zmanim) -> moment(zmanim.sunset()).add(72, 'minutes').seconds(60).format('h:mm')

class HolidayTableFactory
  constructor: (gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, minchaWeek) ->
    [@gregorianWeek, @hebrewWeek, @zmanimWeek, @shaharitWeek, @minchaWeek] = [gregorianWeek, hebrewWeek, zmanimWeek, shaharitWeek, minchaWeek]
  generateTableSection: (iterator) ->
    rowData = @generateRows(iterator)
    rows = rowData.rows
    return if 0 == rows.length
    tableSection = []
    for row in rows
      if row.time?
        tableSection.push("<td>#{row.description}</td><td>#{row.time}</td>")
      else
        tableSection.push("<td colspan=2 class='text-center'><strong>#{row.description}</strong></td>")
    """
      <tr>
        <td rowspan='#{rows.length}'>#{rowData.dayOfWeek}</td>
        <td rowspan='#{rows.length}'>#{rowData.gregorianDate}</td>
        #{tableSection.join("</tr><tr>")}
      </tr>
    """
  generateRows: (iterator) ->
    [gregorianDate, hebrewDate, zmanim, shaharit, mincha] = [@gregorianWeek[iterator], @hebrewWeek[iterator], @zmanimWeek[iterator], @shaharitWeek[iterator], @minchaWeek[iterator]]
    rows = []
    if hebrewDate.isTaanit() && !hebrewDate.is9Ab()
      rows.push(description: "Fast begins", time: zmanim.magenAbrahamDawn().format('h:mm A'))
    if hebrewDate.isPurim()
      rows.push(description: "קְרִיאַת הַמְגִּילִָה", time: morningMegillaTimes(gregorianDate, zmanim))
    if shaharit.hoduLate()? && zmanim.sofZmanKeriatShema().diff(shaharit.hoduLate(), 'minutes') < 60
      rows.push(description: "<strong>Say שְׁמַע יִשְׂרָאֵל before</strong>", time: "<strong>#{zmanim.sofZmanKeriatShema().format("h:mm")}</strong>")
    if hebrewDate.isRoshHashana() && !hebrewDate.isShabbat()
        rows.push(description: "<strong>תְּקִיעַת שׁוֹפַר</strong>", time: "<strong>#{moment(shaharit.hoduLate()).add(150, 'minutes').format('h:mm')}</strong>")
    if hebrewDate.isShabbatZachor()
      rows.push(description: "פְּרָשָׁת זָכוֹר", time: zachorTimes(shaharit))
    if hebrewDate.isShabbatMevarechim()
      hachrazatRoshHodesh = new HachrazatRoshChodesh(hebrewDate)
      rows.push(description: "#{hachrazatRoshHodesh.moladAnnouncement()}<br>#{hachrazatRoshHodesh.sephardicAnnouncement()}")
    if hebrewDate.isHachrazatTaanit()
      rows.push(description: (new HachrazatTaanit(hebrewDate)).announcement())
    if hebrewDate.is9Ab()
      rows.push(description: "חֲצוֹת", time: zmanim.chatzot().format('h:mm A'))
    if hebrewDate.isTaanitEster()
      rows.push(description: "זֵכֶר לְמַחֲצִית הַשֶּׁקֶל")
    if hebrewDate.isTaanit()
      rows.push(description: "Fast ends", time: zmanim.setHaKochabimGeonim().format('h:mm A'))
    if hebrewDate.is9Ab() && 0 == gregorianDate.day()
      rows.push(description: "Say הַבְדָלָה before eating")
    if hebrewDate.isEreb9Ab() && !hebrewDate.isShabbat()
      rows.push(description: "Fast begins", time: zmanim.sunset().format('h:mm'))
    if hebrewDate.is1stDayOfYomTob() && hebrewDate.isShabbat()
      seudat_shelishit_description = "Begin סְעוּדַת שְׁלִישִׁית <strong>at home</strong> before"
      rows.push(description: "<span class='font13'>#{seudat_shelishit_description}</span>", time: zmanim.sunset().format('h:mm'))
    if (hebrewDate.isShabbat() || hebrewDate.isYomTob()) && !hebrewDate.is1stDayOfPesach()  && !hebrewDate.is2ndDayOfPesach() && !hebrewDate.is1stDayOfShabuot() && !hebrewDate.isYomKippur()
      rows.push(description: "Afternoon Shiurim", time: afternoonShiurimTimes(hebrewDate, mincha))
    if hebrewDate.isRoshHashana() && hebrewDate.is1stDayOfYomTob()
      rows.push(description: "תַּשְׁלְיךְ", time: "After מִנְחָה")
    if hebrewDate.is2ndDayOfYomTob() && !hebrewDate.isErebShabbat() && !hebrewDate.isShabbat()
      rows.push(description: "יוֹם טוֹב ends", time: zmanim.setHaKochabim3Stars().format('h:mm'))
    if hebrewDate.isShabbat() && !hebrewDate.isYomKippur()
      unless hebrewDate.is1stDayOfYomTob()
        rows.push(description: seudat_shelishit_in_shul_description(hebrewDate), time: zmanim.sunset().format('h:mm'))
      rows.push(description: "שַׁבָּת ends", time: zmanim.setHaKochabim3Stars().format('h:mm'))
      rows.push(description: "רַבֵּנוּ תָּם", time: rabbenuTamTime(zmanim))
      if zmanim.sunset().isBefore(moment(gregorianDate).hour(18).minute(35)) && !hebrewDate.isErebPurim()
        rows.push(description: "אָבוֹת וּבָּנִים", time: roundedToNearest5Minutes(moment(zmanim.sunset()).add(101, 'minute')).format('h:mm'))
    if hebrewDate.isYomKippur()
      rows.push(description: "נְעִילָה", time: minutesBefore(zmanim.sunset(), 55).format('h:mm'))
      rows.push(description: "בִּרְכַּת כֹּהֲנִים before", time: zmanim.sunset().format('h:mm'))
      rows.push(description: "שׁוֹפַר", time: zmanim.setHaKochabim3Stars().format('h:mm'))
      rows.push(description: "No eating before הַבְדָלָה")
      rows.push(description: "רַבֵּנוּ תָּם", time: rabbenuTamTime(zmanim))
    if hebrewDate.hasHadlakatNerot() || hebrewDate.hasHadlakatNerotAfterSetHaKochabim()
      rows.push(description: "הַדְלַקָת נֵרוֹת", time: hadlakatNerotTime(hebrewDate, zmanim))
      if hebrewDate.yomYobThatWePrayAtPlag() && !hebrewDate.isErebShabbat() && !hebrewDate.isShabbat()
        rows.push(description: "Eat from all cooked foods before #{zmanim.sunset().format('h:mm A')}")
    if hebrewDate.isErebHoshanaRaba()
      rows.push(description: "תִּקוּן לֵיל הוֹשַׁעֲנָא רַבָּא", time: moment(gregorianDate).hour(24).minute(0).format('h:mm A'), tomorrow: true)
    if hebrewDate.isErebShabuot()
      rows.push(description: "תִּקוּן לֵיל שָׁבֻעֹת", time: moment(gregorianDate).hour(24).minute(0).format('h:mm A'), tomorrow: true)
    if hebrewDate.isErebPesach() || hebrewDate.is1stDayOfPesach() || hebrewDate.isErebHoshanaRaba() || hebrewDate.isErebShabuot()
      rows.push(description: "חֲצוֹת", time: moment(zmanim.chatzot()).add(12, 'hours').format('h:mm A'))
    if hebrewDate.isErebPurim()
      minutesAfterSunset = if hebrewDate.isShabbat() then 100 else 21
      rows.push(description: "קְרִיאַת הַמְגִּילִָה", time: roundedToNearest5Minutes(zmanim.sunset()).add(minutesAfterSunset, 'minutes').format('h:mm A'))
    result =
      rows: rows
      dayOfWeek: dayOfWeek(gregorianDate, hebrewDate, rows)
      gregorianDate: gregorianDate.format('D MMM')
    result

(exports ? this).HolidayTableFactory = HolidayTableFactory
