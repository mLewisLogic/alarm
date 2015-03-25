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
    case Sunset  = "sunset"

    static let allValues = [Time, Sunrise, Sunset]
  }

  // Valid values:
  //  sunday, monday, tuesday, wednesday, thursday, friday, saturday
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

  let weekdayToInt = [
    DayOfWeek.Sunday:    1,
    DayOfWeek.Monday:    2,
    DayOfWeek.Tuesday:   3,
    DayOfWeek.Wednesday: 4,
    DayOfWeek.Thursday:  5,
    DayOfWeek.Friday:    6,
    DayOfWeek.Saturday:  7,
  ]


  // For compatability with NSDateComponent
  var weekday: Int {
    get {
      return weekdayToInt[dayOfWeekEnum]!
    }
    set {
      // WTF Swift? I can't easily invert a dictionary?
      // Scan through each key until we find a value that matches
      for key in weekdayToInt.keys {
        let value = weekdayToInt[key]
        if (value == newValue) {
          dayOfWeekEnum = key
          return
        }
      }
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

  // Given a TimePresenter, apply it to this AlarmEntity
  // This supports both time-based and sunrise/sunset TimePresenters
  //
  // NOTE: This is intended to be called exclusively by
  //  AlarmManager.updateAlarmEntity() so that it can notify
  //  the app when this change has global schedule impacts.
  func applyTimePresenter(timePresenter: TimePresenter) {
    // Keep whatever type it was
    self.alarmTypeEnum = timePresenter.type

    // If the presenter is a static time, copy it over. Otherwise,
    // just use the type and allow this instance to figure out it's
    // own sunrise/sunset times.
    switch timePresenter.type {
    case .Time:
      self.hour = Int16(timePresenter.time!.hour24)
      self.minute = Int16(timePresenter.time!.minute)
    default:
      // If it's for sunrise/sunset, just leave invalid sentinel values.
      self.hour = -1
      self.minute = -1
    }

    // Persist the change to the DB
    self.persistSelf()
  }

  // Get a displayable form of the `dayOfWeek` variable.
  func dayOfWeekForDisplay() -> String {
    return dayOfWeek.capitalizedString
  }

  // Generate a displayable version of this time
  func stringForTableDisplay() -> String {
    switch alarmTypeEnum {
    case .Time:
      let time = TimePresenter(alarmEntity: self)
      return time.stringForTableDisplay()
    case .Sunrise:
      return "Sunrise"
    case .Sunset:
      return "Sunset"
    default:
      NSLog("Bad alarm type: \(alarmTypeEnum)")
      return ""
    }
  }

  // When is the next NSDate for this alarm?
  func nextAlarmTime() -> NSDate? {
    if let time = TimePresenter(alarmEntity: self).calculatedTime() {
      // Match on day of week and time
      var matchingComponents = NSDateComponents()
      matchingComponents.weekday = weekday
      matchingComponents.hour = time.hour24
      matchingComponents.minute = time.minute

      // Find the next local time that matches what we're looking for
      // NSCalendar handles timezones for us
      let calendar = NSCalendar.currentCalendar()
      return calendar.nextDateAfterDate(
        NSDate(),
        matchingComponents: matchingComponents,
        options: NSCalendarOptions.MatchNextTime
      )
    } else {
      return nil
    }
  }


  /* Private */

  // Persist the context, and therefore this object
  func persistSelf() {
    NSManagedObjectContext
      .MR_defaultContext()
      .MR_saveToPersistentStoreAndWait()
  }
}
