//= require vendor/hebrewDate

HebrewDate.prototype.yomYobThatWePrayAtPlag = -> @is7thDayOfPesach() || @is1stDayOfShabuot()
HebrewDate.prototype.tonightIsYomTob = -> @isErebYomTob() || @is1stDayOfYomTob()
HebrewDate.prototype.hasHadlakatNerotAfterSetHaKochabim = -> (@isErebYomTob() && @isShabbat()) || (@is1stDayOfYomTob() && !@isErebShabbat())
