//
//  AlarmManager.swift
//  alarm
//
//  Created by Michael Lewis on 3/18/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

// This is responsible for ensuring that the AlarmHelper is always
// loaded with the most impending alarm

// Stash a singleton global instance
private var _overrideAlarm: AlarmEntity?

class AlarmManager {

  // Is it a scheduled alarm or an override?! Who knows?!
  // If there is an override, use that, otherwise
  class func nextAlarm() -> AlarmEntity {
    if let override = _overrideAlarm {
      return override
    } else {
      return nextScheduledAlarm()!
    }
  }

  // Set up an override alarm that takes precedent over the schedule
  class func setOverrideAlarm(timePresenter: TimePresenter) {
    // If this time is the same as the next scheduled alarm, we should
    // actually kill the existing override, if it exists.
    if let scheduledAlarm = nextScheduledAlarm() {
      if timePresenter == TimePresenter(alarmEntity: scheduledAlarm) {
        clearOverrideAlarm()
        return
      }
    }

    // If the incoming time didn't match our next scheduled alarm,
    // we're setting a new override.

    // Use a new context that will never be persisted
    let existingContext = NSManagedObjectContext.MR_context()
    var newContext = NSManagedObjectContext()
    newContext.persistentStoreCoordinator = existingContext.persistentStoreCoordinator
    // Use our new shil context to create an override alarm object
    _overrideAlarm = AlarmEntity.MR_createInContext(newContext) as? AlarmEntity
    _overrideAlarm!.applyTimePresenter(timePresenter)

    // Now we have to figure out what the next time that this
    // alarm would go off at.
    // Match on time
    let rawTime = timePresenter.calculatedTime()!
    var matchingComponents = NSDateComponents()
    matchingComponents.hour = rawTime.hour24
    matchingComponents.minute = rawTime.minute
    let calendar = NSCalendar.currentCalendar()
    let nextTime = calendar.nextDateAfterDate(
      NSDate(),
      matchingComponents: matchingComponents,
      options: NSCalendarOptions.MatchNextTime
    )!
    let weekday = calendar.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: nextTime)
    _overrideAlarm!.weekday = weekday

    updateAlarmHelper()
  }

  // Clear out the override alarm
  class func clearOverrideAlarm() {
    _overrideAlarm = nil
    updateAlarmHelper()
  }

  // True if the the current alarm is an override
  class func isOverridden() -> Bool {
    return _overrideAlarm != nil
  }

  // Update the alarm helper with the impending alarm
  // AlarmHelper is idempotent, so it's alright to spam this function.
  // In practice, this function should be called anytime there is
  // a meaninful change to the persistence layer of alarms, ie. if
  // a user changes an alarm.
  class func updateAlarmHelper() {
    // If we have an override, use that
    if _overrideAlarm != nil {
      AlarmHelper.setAlarm(_overrideAlarm)
    } else {
      // check the schedule and activate the next alarm
      AlarmHelper.setAlarm(nextScheduledAlarm())
    }
  }

  // Get the next scheduled alarm time
  class func nextScheduledAlarm() -> AlarmEntity? {
    // Get all of the known alarms
    let alarms = AlarmEntity.MR_findAll() as [AlarmEntity]
    // Get an array of upcoming alarms, impending first
    let activeAlarms = alarms.filter({
      (alarm: AlarmEntity) -> Bool in
      // Filter out alarms without upcoming times
      alarm.nextAlarmTime() != nil
    }).sorted({
      (a: AlarmEntity, b: AlarmEntity) -> Bool in
      // Sort them by who has the most impending time
      a.nextAlarmTime()!.compare(b.nextAlarmTime()!) == NSComparisonResult.OrderedAscending
    })

    if activeAlarms.count > 0 {
      return activeAlarms.first!
    } else {
      NSLog("How did this happen?!")
      return nil
    }
  }

  // If we don't have any alarms in the system, create
  // initial, default alarms.
  class func createInitialAlarms() {
    AlarmEntity.DayOfWeek.allValues.map {
      (dayOfWeekEnum: AlarmEntity.DayOfWeek) -> () in

      let existingAlarmEntity = AlarmEntity.MR_findFirstByAttribute("dayOfWeek", withValue: dayOfWeekEnum.rawValue) as AlarmEntity?

      // If it's nil, we need to create it
      if existingAlarmEntity == nil {
        var newAlarmEntity = AlarmEntity.MR_createEntity() as AlarmEntity
        newAlarmEntity.dayOfWeekEnum = dayOfWeekEnum
        newAlarmEntity.alarmTypeEnum = .Time
        newAlarmEntity.setValue(true, forKey: "enabled")
        newAlarmEntity.hour = 7
        newAlarmEntity.minute = 0
      }
    }
    // Save newly created records
    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
  }

  // Get alarms in Sunday -> Saturday order
  class func loadAlarmsOrdered() -> [AlarmEntity] {
    var alarms = AlarmEntity.MR_findAll() as [AlarmEntity]
    // Sort them by day of week
    return alarms.sorted {
      (a: AlarmEntity, b: AlarmEntity) -> Bool in
      a.weekday < b.weekday
    }
  }
}
