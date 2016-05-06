minutesBefore = (time, minutes) -> moment(time).subtract(minutes, 'minutes')

NaharShalomScheduleHelpers =
  minutesBefore: minutesBefore
  minutesAfter: (time, minutes) -> minutesBefore(time, -minutes)
  roundedToNearest5Minutes: (time) -> minutesBefore(time, time.minute() % 5).subtract(time.second(), 'seconds')

(exports ? this).NaharShalomScheduleHelpers = NaharShalomScheduleHelpers
