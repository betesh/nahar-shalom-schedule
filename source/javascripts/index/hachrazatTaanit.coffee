class HachrazatTaanit
  constructor: (hebrewDate) ->
    tamuz = hebrewDate.staticHebrewMonth == HebrewMonth.TAMUZ
    @month = if tamuz then "הָרְבִיעִי" else "הָעֲשִׂירִי"
    @dayOfWeek = if 17 == hebrewDate.dayOfMonth then 0 else ((if tamuz then 17 else 10) - hebrewDate.dayOfMonth - 1)
  announcement: -> "אַחֵינוּ בֵּית יִשְׂרָאֵל שְׁמָעוּ, צוֹם #{@month} יִהְיֶה בְּיוֹם #{HEBREW_DAYS[@dayOfWeek]}"

(exports ? this).HachrazatTaanit = HachrazatTaanit
