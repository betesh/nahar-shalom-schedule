//= require ../vendor/hebrewDate
//= require ../site/sunrises
//= require ../site/coordinates
//= require ../site/raven
//= require ../site/shaharit
//= require ../site/sunrise
//= require ../site/zmanim

sedra = (hebrewDate) ->
  if hebrewDate.isMoed() then ("שַׁבָּת חוֹל הַמוֹעֵד " + if hebrewDate.isSukkot() then "סֻּכּוֹת" else "פֶּסַח")
  else if hebrewDate.isYomTob()
    alefOrBet = (if hebrewDate.is1stDayOfYomTob() then "א" else "ב") + "׳ שֶׁל "
    if hebrewDate.isPesach() then (
      if hebrewDate.is8thDayOfPesach() then "אַחֲרוֹן שֶׁל פֶּסַח"
      else if hebrewDate.is7thDayOfPesach() then "שְׁבִיעִי שֶׁל פֶּסַח"
      else "#{alefOrBet}פֶּסַח"
      )
    else if hebrewDate.isShabuot() then "#{alefOrBet}שָׁבֻעֹת"
    else if hebrewDate.isRoshHashana() then "#{alefOrBet}רֹאשׁ הַשָּׁנָה"
    else if hebrewDate.isSukkot() then (
      if hebrewDate.isSheminiAseret() then (if hebrewDate.is1stDayOfYomTob() then "שְּׁמִינִי עֲצֶרֶת" else"שִׂמְחַת תּוֹרָה")
      else"#{alefOrBet}סֻּכּוֹת"
    )
  else if hebrewDate.isYomKippur() then "יוֹם הַכִּפֻּרִים"
  else hebrewDate.sedra()

generateTable = (year, rows) ->
  """
    <table class='table table-striped table-condensed'>
      #{tableHeader(year)}
      #{rows.join('')}
    </table>
  """

tableHeader = (year) ->
  """
    <tr>
      <th>#{year}</th>
      <th></th>
      <th></th>
      <th>קָרְבָּנוֹת</th>
      <th>Say בְּרָכָה on<br>טַלִית after</th>
      <th>הוֹדוּ</th>
      <th>נִשְׁמַת כָּל-חַי</th>
      <th>עֲמִידָה</th>
    </tr>
  """

tableRow = (momentInstance, hebrewDate) ->
  sunrise = new Sunrise(momentInstance).time()
  shaharit = new Shaharit(hebrewDate, sunrise)
  return unless shaharit.hoduLate()?
  firstDayOfYear = hebrewDate.isRoshHashana() && hebrewDate.is1stDayOfYomTob()
  sunrise = shaharit.amidahVatikin().format("h:mm:ss")
  nishmat = shaharit.nishmatVatikin().format("h:mm")
  hodu = shaharit.hoduVatikin().format("h:mm")
  korbanot = shaharit.korbanotVatikin().format("h:mm")
  showGregorianYear = (hebrewDate.isRoshHashana() && hebrewDate.is1stDayOfYomTob()) || (0 == momentInstance.month() && momentInstance.date() <= 7)
  gregorianDate = momentInstance.format("MMM D#{if showGregorianYear then " YYYY" else ""}")
  earliestTallit = (new Zmanim(hebrewDate.gregorianDate, window.coordinates)).earliestTallit().format("h:mm:ss")
  """
    <tr>
      <td>#{hebrewDate.dayOfMonth} #{hebrewDate.staticHebrewMonth.name}</td>
      <td>#{gregorianDate}</td>
      <td>#{sedra(hebrewDate)}</td>
      <td>#{korbanot}</td>
      <td>#{earliestTallit}</td>
      <td>#{hodu}</td>
      <td>#{nishmat}</td>
      <td>#{sunrise}</td>
    </tr>
  """

updateTable = ->
  value = this.value
  window.catchingErrors 'Shabbat', value, -> updateTableInTryCatch(value)

updateTableInTryCatch = (value) ->
  year = parseInt(value)
  hebrewDate =  new HebrewDate(new RoshHashana(year).getGregorianDate())
  screenRows = []
  printRows = []
  printTables = []
  i = 1
  while hebrewDate.getYearFromCreation() == year
    gregorianDate = hebrewDate.gregorianDate
    momentInstance = moment(gregorianDate)
    if momentInstance.isAfter(moment("2015-11-08", "YYYY-MM-DD")) && (hebrewDate.isShabbat() || hebrewDate.isYomTob() || hebrewDate.isYomKippur())
      row = tableRow(momentInstance, hebrewDate)
      printRows.push(row)
      screenRows.push(row)
      if 19 == (i % 22)
        printTables.push(generateTable(year, printRows))
        printRows = []
      i++
    gregorianDate.setDate(gregorianDate.getDate() + 1)
    hebrewDate = new HebrewDate(gregorianDate)
  printTables.push(generateTable(year, printRows)) unless 0 == printRows.length
  html = """
    <div class='print-only'>
      #{printTables.join("<p class='page-break-before'>&nbsp;</p>")}
    </div>
    <div class='screen-only'>
      #{generateTable(year, screenRows)}
    </div>
  """
  $(".vatikin-schedule").html(html)

$ ->
  validYears = []
  initialDate = window.location.search.replace("?", "")
  for year, sunrises of window.sunrises
    validYears.push(year)
    if parseInt(year) >= 5776
      $("select.year-select").append($("<option>", { text: year }))
  $("select.year-select").change updateTable
  unless  initialDate in validYears
    initialDate = new Date()
    initialDate.setDate(initialDate.getDate() + 2)
    initialDate = new HebrewDate(initialDate).getYearFromCreation()
  $("select.year-select").val(initialDate)
  $("select.year-select").change()
