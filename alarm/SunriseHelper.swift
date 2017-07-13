//
//  SunriseSetHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/14/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import CoreLocation
import UIKit
import EDSunriseSet


// Stash a singleton global instance
private let _SunriseHelperSharedInstance = SunriseHelper()

class SunriseHelper {

  let calendar: Calendar
  // We'll only have a valid calculator when we can get location
  var calculator: EDSunriseSet?
  // Store the last time we ran the sunrise/sunset calculations.
  // They need to be re-run every time we roll over a day or move too far.
  var lastCalculation: Date?
  var lastLocation: CLLocation?

  let distanceRecalcThreshold = 50000.0 // 50km

  init() {
    calendar = Calendar.autoupdatingCurrent
  }

  // Create and hold onto a singleton instance of this class
  // because calculations and heavy and should be cached
  // for performance reasons.
  class var singleton: SunriseHelper {
    return _SunriseHelperSharedInstance
  }

  // Return a RawTime struct set to sunrise
  // This is clearly only valid for the day it was generated
  func sunrise() -> RawTime? {
    self.updateIfNeeded()

    if let calc = self.calculator {
      return getRawTimeForLocalNSDate(calc.sunrise)
    } else {
      return nil
    }
  }

  // Return a RawTime struct set to sunset
  // This is clearly only valid for the day it was generated
  func sunset() -> RawTime? {
    self.updateIfNeeded()

    if let calc = self.calculator {
      return getRawTimeForLocalNSDate(calc.sunset)
    } else {
      return nil
    }
  }


  /* Private */

  // If we haven't recalculated sunrise and sunset for today
  // then recalculate here and timestamp it.
  fileprivate func updateIfNeeded() {
    if (calculator == nil || lastCalculationIsStale() || lastLocationIsStale()) {
      // We can only update if we have a location
      if let newLocation = currentLocation() {
        // We got here if we need to recalculate
        NSLog("Recalculating sunrise and sunset")
        self.lastCalculation = Date()
        self.lastLocation = newLocation

        calculator = EDSunriseSet(
          timezone: TimeZone.current,
          latitude: newLocation.coordinate.latitude,
          longitude: newLocation.coordinate.longitude
        )
        calculator!.calculateSunriseSunset(self.lastCalculation)
      }
    }
  }

  fileprivate func lastCalculationIsStale() -> Bool {
    if let lastCalc = lastCalculation {
      if calendar.isDateInToday(lastCalc as Date) {
        // The `lastCalc` NSDate is within today. Skip calculations.
        return false
      }
    }
    return true
  }

  // Return true if we don't have a lastLocation or if it has drifted
  // too far from where we last calculated.
  fileprivate func lastLocationIsStale() -> Bool {
    if let lastLoc = lastLocation {
      if let currentLoc = currentLocation() {
        if (currentLoc.distance(from: lastLoc) < distanceRecalcThreshold) {
          return false
        }
      }
    }
    return true
  }

  // Ask the LocationHelper for our latest location
  fileprivate func currentLocation() -> CLLocation? {
    return LocationHelper.singleton.latestLocation
  }

  // Get the NSDateComponents for the current calendar/timezone
  // given an input NSDate.
  fileprivate func getLocalHourMinuteComponents(_ date: Date) -> DateComponents {
    return calendar.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: date)
  }

  fileprivate func getRawTimeForLocalNSDate(_ date: Date) -> RawTime {
    let components = getLocalHourMinuteComponents(date)
    return RawTime(
      hour24: components.hour!,
      minute: components.minute!
    )
  }
}
