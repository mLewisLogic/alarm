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

  func applyTimePresenter(time: TimePresenter) {
    self.alarmTypeEnum = .Time
    self.hour = Int16(time.hour24)
    self.minute = Int16(time.minute)
    self.persistSelf()
  }

  func dayOfWeekForDisplay() -> String {
    return dayOfWeek.capitalizedString
  }

  // Generate a displayable version of this time
  func timeForTableDisplay() -> String {
    switch alarmTypeEnum {
    case .Time:
      let time = TimePresenter(alarmEntity: self)
      return time.tableDisplayStr()
    case .Sunrise:
      return "sunrise"
    case .Sunset:
      return "sunset"
    default:
      NSLog("Bad alarm type: \(alarmTypeEnum)")
      return ""
    }
  }

  // Update the persistance layer for this alarm
  func updateTime(type: AlarmType, hour: Int16?, minute: Int16?) {
    self.alarmTypeEnum = type
    self.hour = hour ?? 0
    self.minute = minute ?? 0

    self.persistSelf()
  }

  private func persistSelf() {
  }
}
