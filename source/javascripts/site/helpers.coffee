minutesBefore = (time, minutes) -> moment(time).subtract(minutes, 'minutes')
roundedToNearestNMinutes = (time, n) -> minutesBefore(time, time.minute() % n).subtract(time.second(), 'seconds')

NaharShalomScheduleHelpers =
  minutesBefore: minutesBefore
  minutesAfter: (time, minutes) -> minutesBefore(time, -minutes)
  roundedToNearest5Minutes: (time) -> roundedToNearestNMinutes(time, 5)
  roundedToNearest15Minutes: (time) -> roundedToNearestNMinutes(time, 15)

(exports ? this).NaharShalomScheduleHelpers = NaharShalomScheduleHelpers
