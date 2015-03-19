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

  // For compatability with NSDateComponent
  var weekday: Int {
    get {
      switch dayOfWeekEnum {
      case .Sunday:
        return 1
      case .Monday:
        return 2
      case .Tuesday:
        return 3
      case .Wednesday:
        return 4
      case .Thursday:
        return 5
      case .Friday:
        return 6
      case .Saturday:
        return 7
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
      return "sunrise"
    case .Sunset:
      return "sunset"
    default:
      NSLog("Bad alarm type: \(alarmTypeEnum)")
      return ""
    }
  }

  // If this alarm is enabled, when is the next NSDate
  // for it?
  // This currently does not handle individual days.
  func nextAlarmTime() -> NSDate? {
    if self.enabled {
      // Match on day of week and time
      var matchingComponents = NSDateComponents()
      matchingComponents.weekday = weekday
      matchingComponents.hour = Int(hour)
      matchingComponents.minute = Int(minute)

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
