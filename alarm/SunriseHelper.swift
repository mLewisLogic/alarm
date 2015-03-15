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

  let calculator: EDSunriseSet
  let calendar: NSCalendar
  var lastCalc: NSDate?

  init() {
    calculator = EDSunriseSet(
      timezone: NSTimeZone.localTimeZone(),
      latitude: 37.7833,
      longitude: -122.4167
    )
    calendar = NSCalendar.currentCalendar()
  }

  // Return a TimePresenter set to sunrise
  func sunrise() -> TimePresenter {
    let components = getLocalHourMinuteComponents(calculator.sunrise)
    return TimePresenter(
      hour24: components.hour,
      minute: components.hour,
      type: .Sunrise
    )
  }

  // Return a TimePresenter set to sunset
  func sunset() -> TimePresenter {
    let components = getLocalHourMinuteComponents(calculator.sunset)
    return TimePresenter(
      hour24: components.hour,
      minute: components.hour,
      type: .Sunset
    )
  }


  // If we haven't recalculated sunrise and sunset for today
  private func updateIfNeeded() {
    if let last = lastCalc {
      if calendar.isDateInToday(last) {
        // The `lastCalc` NSDate is within today. Skip calculations.
        return
      }
    }

    // We got here if we need to recalculate
    lastCalc = NSDate()
    calculator.calculateSunriseSunset(lastCalc)
  }

  private func getLocalHourMinuteComponents(date: NSDate) -> NSDateComponents {
    return calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
  }

  class var singleton: SunriseHelper {
    return _SunriseHelperSharedInstance
  }
}
