//
//  TimePresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/8/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class TimePresenter {
  let hour24: Int
  let hour12: Int
  let minute: Int
  let amOrPm: String // either "am" or "pm"
  // Support time-based, or sunrise/sunset based
  let type: AlarmEntity.AlarmType


  // Default to the time type but allow overriding
  init(hour24: Int, minute: Int, type: AlarmEntity.AlarmType = .Time) {
    self.hour24 = hour24
    self.minute = minute
    self.type = type

    // Determine AM vs PM and adjust the hour to a 12 hour clock
    if hour24 < 12 {
      self.hour12 = hour24
      self.amOrPm = "am"
    } else {
      self.hour12 = hour24 - 12
      self.amOrPm = "pm"
    }

    if self.hour24 == 0 {
      self.hour24 = 12
    }
  }

  convenience init(alarmEntity: AlarmEntity) {
    self.init(hour24: Int(alarmEntity.hour), minute: Int(alarmEntity.minute))
  }

  convenience init(type: AlarmEntity.AlarmType) {
    switch type {
    case .Time:
      NSLog("This is being improperly initialized. The alarm type initializer is not for .Time")
      self.init(hour24: 0, minute: 0)
    case .Sunrise:
      self.init(hour24: 0, minute: 0)
    case .Sunset:
      self.init(hour24: 0, minute: 0)
    }
  }


  // Don't include the am/pm portion in the main wheel
  func wheelDisplayStr() -> String {
    switch self.type {
    case .Time:
      // Special formatting for special times
      if hour24 == 0 && minute == 0 {
        return "midnight"
      } else if hour24 == 12 && minute == 0 {
        return "noon"
      } else {
        return String(format: "%02d : %02d", self.hour12, self.minute)
      }
    case .Sunrise:
      return "sunrise"
    case .Sunset:
      return "sunset"
    }
  }

  func tableDisplayStr() -> String {
    switch self.type {
    case .Time:
      // Special formatting for special times
      if hour24 == 0 && minute == 0 {
        return "midnight"
      } else if hour24 == 12 && minute == 0 {
        return "noon"
      } else {
        return String(format: "%02d:%02d %@", self.hour12, self.minute, self.amOrPm)
      }
    case .Sunrise:
      return "sunrise"
    case .Sunset:
      return "sunset"
    }
  }

  // Generate all of the time elements that we will allow
  class func generateAllElements() -> Array<TimePresenter> {
    return (0...23).map {
      hour in
      [0, 15, 30, 45].map {
        minute in
        TimePresenter(hour24: hour, minute: minute)
      }
    }.reduce([], +)
  }
}
