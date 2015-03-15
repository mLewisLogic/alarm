//
//  TimePresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/8/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class TimePresenter: Comparable {
  // Support time-based, or sunrise/sunset based
  let type: AlarmEntity.AlarmType
  let time: RawTime?

  // Time type is required, and a raw time is optional
  init(type: AlarmEntity.AlarmType, time: RawTime? = nil) {
    self.type = type
    self.time = time

    // If we're dealing with an AlarmType of .Time, ensure
    // that we have a valid `time`.
    if type == .Time {
      assert(time != nil)
    }
  }

  // Allow creation by raw hours/minutes
  convenience init(hour24: Int, minute: Int) {
    self.init(type: .Time, time: RawTime(hour24: hour24, minute: minute))
  }

  // Create a TimePresenter, using an AlarmEntity as the base
  convenience init(alarmEntity: AlarmEntity) {
    switch alarmEntity.alarmTypeEnum {
    case .Time:
      self.init(
        hour24: Int(alarmEntity.hour),
        minute: Int(alarmEntity.minute)
      )
    default:
      self.init(type: alarmEntity.alarmTypeEnum)
    }
  }

  // This presenter supports static times as well as sun-based times
  // This function will return a raw time representing what the
  // true time is, no matter how this presenter was constructed.
  func calculatedTime() -> RawTime {
    switch self.type {
    case .Time:
      return time!
    case .Sunrise:
      return SunriseHelper.singleton.sunrise()
    case .Sunset:
      return SunriseHelper.singleton.sunset()
    }
  }

  // Don't include the am/pm portion in the main wheel
  func stringForWheelDisplay() -> String {
    // Precalculate the time for speed
    let time = calculatedTime()

    switch self.type {
    case .Time:
      // Special formatting for special times
      if time.hour24 == 0 && time.minute == 0 {
        return "midnight"
      } else if time.hour24 == 12 && time.minute == 0 {
        return "noon"
      } else {
        return String(format: "%02d : %02d", time.hour12, time.minute)
      }
    case .Sunrise:
      return String(format: "sunrise (%02d:%02d)", time.hour12, time.minute)
    case .Sunset:
      return String(format: "sunset (%02d:%02d)", time.hour12, time.minute)
    }
  }

  // The table display view doesn't need times for sunrise/sunset
  func stringForTableDisplay() -> String {
    // Precalculate the time for speed
    let time = calculatedTime()

    switch self.type {
    case .Time:
      // Special formatting for special times
      if time.hour24 == 0 && time.minute == 0 {
        return "midnight"
      } else if time.hour24 == 12 && time.minute == 0 {
        return "noon"
      } else {
        return String(format: "%02d:%02d %@", time.hour12, time.minute, self.amPmToString(time.amOrPm))
      }
    case .Sunrise:
      return "sunrise"
    case .Sunset:
      return "sunset"
    }
  }

  // Generate all of the time elements that we will allow
  // This includes sunset and sunrise.
  class func generateAllElements() -> Array<TimePresenter> {
    // Start by generating the static times
    var times = (0...23).map {
      hour in
      [0, 15, 30, 45].map {
        minute in
        TimePresenter(hour24: hour, minute: minute)
      }
    }.reduce([], +)

    // Add in sunrise and sunset
    times.append(TimePresenter(type: AlarmEntity.AlarmType.Sunrise))
    times.append(TimePresenter(type: AlarmEntity.AlarmType.Sunset))

    // Sort the entire array, based upon calculated time
    return times.sorted { $0 < $1 }
  }


  /* Private */

  private func amPmToString(amPm: RawTime.AmPm) -> String {
    switch amPm {
    case .AM:
      return "am"
    case .PM:
      return "pm"
    }
  }
}

// Comparison operators for TimePresenter
func <(left: TimePresenter, right: TimePresenter) -> Bool {
  return left.calculatedTime() < right.calculatedTime()
}

func ==(left: TimePresenter, right: TimePresenter) -> Bool {
  // They have to share the same type to be equal
  if left.type == right.type {
    switch left.type {
    case .Time:
      // If it's static time, make sure it's the same
      return left.time == right.time
    default:
      // If it's sunrise/sunset, type alone is enough
      return true
    }
  } else {
    // If type is different, they're inequal
    return false
  }
}
