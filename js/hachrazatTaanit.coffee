class HachrazatTaanit
  constructor: (hebrew_date) ->
    tamuz = hebrew_date.staticHebrewMonth == HebrewMonth.TAMUZ
    @month = if tamuz then "הָרְבִיעִי" else "הָעֲשִׂירִי"
    @dayOfWeek = if 17 == hebrew_date.dayOfMonth then 0 else ((if tamuz then 17 else 10) - hebrew_date.dayOfMonth - 1)
  announcement: -> "אַחֵינוּ בֵּית יִשְׂרָאֵל שְׁמָעוּ, צוֹם #{@month} יִהְיֶה בְּיוֹם #{NextMonth.HEBREW_DAYS[@dayOfWeek]}"

(exports ? this).HachrazatTaanit = HachrazatTaanit
