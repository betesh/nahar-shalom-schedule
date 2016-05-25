//= require vendor/hebrewDate

HebrewDate.prototype.yomYobThatWePrayAtPlag = -> @is7thDayOfPesach() || @is1stDayOfShabuot()
HebrewDate.prototype.tonightIsYomTob = -> @isErebYomTob() || @is1stDayOfYomTob()
HebrewDate.prototype.hasHadlakatNerotAfterSetHaKochabim = -> (@isErebYomTob() && @isShabbat()) || (@is1stDayOfYomTob() && !@isErebShabbat())
HebrewDate.prototype.hasHadlakatNerot = -> @isErebShabbat() || @isErebYomTob() || @isErebYomKippur()
HebrewDate.prototype.isNesiim = -> @monthAndRangeAre('NISAN', [1,2,3,4,5,6,7,8,9,10,11,12,13])
HebrewDate.prototype.isErebPurim = -> @monthAndRangeAre('ADAR', 13) || @monthAndRangeAre('ADAR_SHENI', 13)
