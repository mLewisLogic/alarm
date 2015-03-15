//
//  SunriseSetHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/14/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation


private let _SunriseHelperSharedInstance = SunriseHelper()

class SunriseHelper {

  let calendar: NSCalendar
  let calculator: EDSunriseSet
  // Store the last time we ran the sunrise/sunset calculations.
  // They need to be re-run every time we roll over a day.
  var lastCalculation: NSDate?

  init() {
    calendar = NSCalendar.currentCalendar()
    calculator = EDSunriseSet(
      timezone: NSTimeZone.localTimeZone(),
      latitude: 37.7833,
      longitude: -122.4167
    )
  }

  // Create and hold onto a singleton instance of this class
  // because calculations and heavy and should be cached
  // for performance reasons.
  class var singleton: SunriseHelper {
    return _SunriseHelperSharedInstance
  }

  // Return a RawTime struct set to sunrise
  // This is clearly only valid for the day it was generated
  func sunrise() -> RawTime {
    self.updateIfNeeded()
    return getRawTimeForLocalNSDate(calculator.sunrise)
  }

  // Return a RawTime struct set to sunset
  // This is clearly only valid for the day it was generated
  func sunset() -> RawTime {
    self.updateIfNeeded()
    return getRawTimeForLocalNSDate(calculator.sunset)
  }


  /* Private */

  // If we haven't recalculated sunrise and sunset for today
  // then recalculate here and timestamp it.
  private func updateIfNeeded() {
    if let lastCalc = lastCalculation {
      if calendar.isDateInToday(lastCalc) {
        // The `lastCalc` NSDate is within today. Skip calculations.
        return
      }
    }

    // We got here if we need to recalculate
    NSLog("Recalculating sunrise and sunset")
    self.lastCalculation = NSDate()
    calculator.calculateSunriseSunset(self.lastCalculation)
  }

  // Get the NSDateComponents for the current calendar/timezone
  // given an input NSDate.
  private func getLocalHourMinuteComponents(date: NSDate) -> NSDateComponents {
    return calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
  }

  private func getRawTimeForLocalNSDate(date: NSDate) -> RawTime {
    let components = getLocalHourMinuteComponents(date)
    return RawTime(
      hour24: components.hour,
      minute: components.minute
    )
  }
}
