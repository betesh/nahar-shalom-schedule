# TODO: Port this back into HebrewDateJS and test it.

class NextMonth
  constructor: (hebrew_date) ->
    @shabbatMevarchim = hebrew_date
    hebrewYear = hebrew_date.getHebrewYear()
    months = HebrewMonth.MONTHS.ofYear(hebrewYear)
    monthIndex = months.indexOf(hebrew_date.staticHebrewMonth) + 1
    @name = months[monthIndex].name
    molad = hebrewYear.getThisRoshHashana().getMolad().advance(monthIndex)
    @moladHours = molad.getHours() - 6
    yesterday = @moladHours < 0
    @pm = yesterday || @moladHours >= 12
    @moladHours = (@moladHours + 12) % 12
    @moladHours = 12 if 0 == @moladHours
    @moladMinutes = "0#{parseInt(molad.getHalakim() / 18)}"[-2..-1]
    @moladHalakim = molad.getHalakim() % 18
    @dayOfMolad = switch
      when 0 == molad.getDay() && yesterday then "מוֹצָאֵי שַּׁבָּת"
      when 6 == molad.getDay() then "#{if yesterday then "לֵיל " else ""} שַּׁבָּת"
      else "#{moment.weekdays(molad.getDay() - (if yesterday then 1 else 0))} #{if yesterday then "night " else ""}"
  announcement: -> "בְּסִימַן טוֹב יְהֵא לָנוּ רֹאשׁ חֹדֶשׁ #{@name} בְּיוֹם #{if @is2Days() then "#{@dayOfWeek30()} וּבְיוֹם " else ""}#{@dayOfWeek1()}"
  moladAnnouncement: -> "The מוֹלַד of חֹדֶשׁ #{@name} will be on #{@dayOfMolad} at #{@moladHours}:#{@moladMinutes}#{if @pm then "P" else "A"}M and #{@moladHalakim} חָלָקִים"
  dayOfWeek1Index: -> @shabbatMevarchim.getHebrewMonth().getNextRoshHodesh().getDay()
  dayOfWeek1: -> NextMonth.HEBREW_DAYS[@dayOfWeek1Index()]
  dayOfWeek30: -> NextMonth.HEBREW_DAYS[(@dayOfWeek1Index() + 6) % 7]
  is2Days: -> 30 == @shabbatMevarchim.getHebrewMonth().getLength()

NextMonth.HEBREW_DAYS = ['רִאשׁוֹן', 'שֵׁנִי', 'שְׁלִישִׁי', 'רְבִיעִי', 'חֲמִישִׁי', 'הַשִּׁשִּׁי', 'שַּׁבָּת קֹדֶשׁ']

(exports ? this).NextMonth = NextMonth
