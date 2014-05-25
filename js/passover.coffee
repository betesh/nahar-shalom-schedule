###
    MIT LICENSE
    (c) Isaac Betesh
    refactored from https://github.com/betesh/hebcal/
###

### Constant for calculating date of Pesach ###
HALAKIM_PER_HOUR = 1080
HALAKIM_PER_DAY = 24 * HALAKIM_PER_HOUR
ANNUAL_DRIFT = 10 * HALAKIM_PER_DAY + 21 * HALAKIM_PER_HOUR + 204
JULIAN_ANNUAL_CALENDAR_DRIFT = HALAKIM_PER_HOUR * 6
JULIAN_YEAR = 365.25 * HALAKIM_PER_DAY

LUNAR_CYCLE = 29 * HALAKIM_PER_DAY + 12 * HALAKIM_PER_HOUR + 793
HALAKIM_PER_19_YEAR_CYCLE = 235 * LUNAR_CYCLE

JULIAN_ERROR_PER_19_YEAR_CYCLE = JULIAN_YEAR * 19 - HALAKIM_PER_19_YEAR_CYCLE
EPOCH_TEKUFAH = -(20 * HALAKIM_PER_HOUR + 302)

MOLAD_ZAQEN = 6 * HALAKIM_PER_HOUR
TUTAKPAT = 15 * HALAKIM_PER_HOUR + 589
TARAD = 9 * HALAKIM_PER_HOUR + 204

is_leap_year = (year) -> (year % 19) in [3,6,8,11,14,17,19]
precedes_leap_year = (year) -> is_leap_year(year+1)
gregorian_divergence = (yearG) -> Math.floor(yearG/100) - Math.floor(yearG/400) - 2
drift_since_epoch = (yearH) -> (LUNAR_CYCLE + EPOCH_TEKUFAH + (LUNAR_CYCLE - ANNUAL_DRIFT) * (yearH % 19) - HALAKIM_PER_DAY) % LUNAR_CYCLE

window.pesach_in_gregorian_year = (yearG) ->
  yearH = yearG + 3760
  year_in_julian_cycle = yearG % 4
  molad = LUNAR_CYCLE + HALAKIM_PER_DAY + MOLAD_ZAQEN + drift_since_epoch(yearH) + (year_in_julian_cycle * JULIAN_ANNUAL_CALENDAR_DRIFT) - (JULIAN_ERROR_PER_19_YEAR_CYCLE * Math.floor(yearH / 19))
  halakim_into_day = molad % HALAKIM_PER_DAY
  pesach_julian_day = (molad - halakim_into_day) / HALAKIM_PER_DAY

  day_of_week = ((3 * yearG) + (5 * year_in_julian_cycle) + pesach_julian_day) % 7
  pesach_day = pesach_julian_day + gregorian_divergence(yearG)

  if day_of_week in [1,3,5]
    pesach_day += 1
  else if (0 == day_of_week && !precedes_leap_year(yearH) && halakim_into_day >= TARAD + MOLAD_ZAQEN)
    pesach_day += 2
  else if (6 == day_of_week && is_leap_year(yearH) && halakim_into_day >= TUTAKPAT + MOLAD_ZAQEN)
    pesach_day += 1
  pesach_month = 2
  new Date(yearG, pesach_month, pesach_day)
