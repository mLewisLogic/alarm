//
//  AlarmEntity.swift
//  alarm
//
//  Created by Michael Lewis on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation
import CoreData

@objc(AlarmEntity)
class AlarmEntity: NSManagedObject {

  enum DayOfWeek: String {
    case Sunday    = "sunday"
    case Monday    = "monday"
    case Tuesday   = "tuesday"
    case Wednesday = "wednesday"
    case Thursday  = "thursday"
    case Friday    = "friday"
    case Saturday  = "saturday"

    static let allValues = [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
  }

  enum AlarmType: String {
    case Time    = "time"
    case Sunrise = "sunrise"
    case Sunset  = "Sunset"

    static let allValues = [Time, Sunrise, Sunset]
  }

  // Valid values: sunday, monday, tuesday, wednesday, thursday, friday, saturday
  @NSManaged private var dayOfWeek: String
  // Valid values: time, sunrise, sunset
  @NSManaged private var alarmType: String
  // Valid values: true, false
  @NSManaged var enabled: Bool
  // Valid values: 0-23
  @NSManaged var hour: Int16
  // Valid values: 0, 15, 30, 45
  @NSManaged var minute: Int16

  // Provide a set of enum accessors for the private `dayOfWeek`
  var dayOfWeekEnum: DayOfWeek {
    get {
      return DayOfWeek(rawValue: dayOfWeek)!
    }
    set {
      dayOfWeek = newValue.rawValue
    }
  }

  // Provide a set of enum accessors for the private `alarmType`
  var alarmTypeEnum: AlarmType {
    get {
      return AlarmType(rawValue: alarmType)!
    }
    set {
      alarmType = newValue.rawValue
    }
  }

  func applyTimeElement(timeElement: TimeElement) {
    alarmTypeEnum = .Time
    // Convert hour + am/pm to 24-hour
    hour = Int16(timeElement.hour + (timeElement.amOrPm == "pm" ? 12 : 0))
    minute = Int16(timeElement.minute)
  }

  func dayOfWeekForDisplay() -> String {
    return dayOfWeek.capitalizedString
  }

  // Generate a displayable version of this time
  func timeForTableDisplay() -> String {
    switch alarmTypeEnum {
    case .Time:
      let timeElement = TimeElement(hour: Int(hour), minute: Int(minute))
      return timeElement.tableDisplayStr()
    case .Sunrise:
      return "sunrise"
    case .Sunset:
      return "sunset"
    default:
      NSLog("Bad alarm type: \(alarmTypeEnum)")
      return ""
    }
  }
}
