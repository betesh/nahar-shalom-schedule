sedra = (hebrewDate) ->
  if hebrewDate.isYomKippur() then "יוֹם הַכִּפֻּרִים"
  else if hebrewDate.isYomTob() then ""
  else if hebrewDate.isMoed() then ""
  else hebrewDate.sedra()
tableRow = (momentInstance, hebrewDate) ->
  vatikin = new Vatikin(momentInstance, hebrewDate)
  firstDayOfYear = hebrewDate.isRoshHashana() && hebrewDate.is1stDayOfYomTob()
  sunrise = vatikin.sunrise.format("h:mm:ss")
  yishabach = vatikin.sunrise.subtract(vatikin.schedule.yishtabach, 'minutes').format("h:mm")
  hodu = vatikin.sunrise.subtract(vatikin.schedule.hodu, 'minutes').format("h:mm")
  korbanot = vatikin.sunrise.subtract(vatikin.schedule.korbanot, 'minutes').format("h:mm")
  """
    <tr>
      <td>#{hebrewDate.dayOfMonth} #{hebrewDate.staticHebrewMonth.name}</td>
      <td>#{momentInstance.format("MMMM D#{if (hebrewDate.isRoshHashana() && hebrewDate.is1stDayOfYomTob()) || (0 == momentInstance.month() && momentInstance.date() <= 7) then " YYYY" else ""}")}</td>
      <td>#{sedra(hebrewDate)}</td>
      <td>#{korbanot}</td>
      <td>#{hodu}</td>
      <td>#{yishabach}</td>
      <td>#{sunrise}</td>
    </tr>
  """

update_table = ->
  $("table.vatikin-schedule tr").not(":nth-child(1)").remove()
  year = parseInt(this.value)
  $("table.vatikin-schedule tr:nth-child(1) th:nth-child(1)").html(year)
  hebrewDate =  new HebrewDate(new RoshHashana(year).getGregorianDate())
  while hebrewDate.getYearFromCreation() == year
    gregorianDate = hebrewDate.gregorianDate
    momentInstance = moment(gregorianDate)
    if momentInstance.isAfter(moment(new Date("11-8-2015"))) && (hebrewDate.isShabbat() || hebrewDate.isYomTob() || hebrewDate.isYomKippur())
      $("table.vatikin-schedule").append(tableRow(momentInstance, hebrewDate))
    gregorianDate.setDate(gregorianDate.getDate() + 1)
    hebrewDate = new HebrewDate(gregorianDate)

$ ->
  validYears = []
  initialDate = window.location.search.replace("?", "")
  for year, sunrises of window.sunrises
    validYears.push(year)
    if parseInt(year) >= 5776
      $("select.year_select").append($("<option>", { text: year }))
  $("select.year_select").change update_table
  unless  initialDate in validYears
    initialDate = new Date()
    initialDate.setDate(initialDate.getDate() + 2)
    initialDate = new HebrewDate(initialDate).getYearFromCreation()
  $("select.year_select").val(initialDate)
  $("select.year_select").change()
