//
//  AlarmManager.swift
//  alarm
//
//  Created by Michael Lewis on 3/18/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit
import CoreData

// This is responsible for ensuring that the AlarmHelper is always
// loaded with the most impending alarm.
// It manages the override alarm, the handling of the persisted scheduled
// alarms, and

// Stash a singleton global instance
private let _alarmManager = AlarmManager()

class AlarmManager: NSObject {

  // Stash a singleton global instance
  var overrideAlarm: AlarmEntity?

  // This class uses a dummy context to hold the override alarms
  var dummyContext: NSManagedObjectContext

  override init() {
    // Use a new context that will never be persisted
    dummyContext = NSManagedObjectContext()
    let existingContext = NSManagedObjectContext.mr_()
    // Borrow the existing store coordinator, just never persist
    dummyContext.persistentStoreCoordinator = existingContext.persistentStoreCoordinator
    super.init()
  }

  // Create and hold onto a singleton instance of this class
  class var singleton: AlarmManager {
    return _alarmManager
  }



  // Is it a scheduled alarm or an override?! Who knows?!
  // If there is an override, use that, otherwise
  class func nextAlarm() -> AlarmEntity {
    if let override = singleton.overrideAlarm {
      return override
    } else {
      return nextScheduledAlarm()
    }
  }

  // Allow for the update of an AlarmEntity
  // This provides support for sending out a notification if the update
  // also changed the impending alarm.
  class func updateAlarmEntity(_ alarm: AlarmEntity, timePresenter: TimePresenter) {
    let nextAlarm = nextScheduledAlarm()
    let originalNextScheduledAlarmTime = nextAlarm.nextAlarmTime()
    alarm.applyTimePresenter(timePresenter)
    // If this changed the nextScheduledAlarm, we have updating to do.
    let newNextScheduledAlarmTime = nextAlarm.nextAlarmTime()
    if originalNextScheduledAlarmTime != newNextScheduledAlarmTime {
      NSLog("Next scheduled time has changed")
      clearOverrideAlarm()
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: Notifications.NextScheduledAlarmChanged),
        object: nextAlarm
      )
    }
  }

  // Set up an override alarm that takes precedent over the schedule
  class func setOverrideAlarm(timePresenter: TimePresenter) {
    // If this time is the same as the next scheduled alarm, we should
    // actually kill the existing override, if it exists.
    if timePresenter == TimePresenter(alarmEntity: nextScheduledAlarm()) {
      clearOverrideAlarm()
      return
    }

    // If the incoming time didn't match our next scheduled alarm,
    // we're setting a new override.

    // Use our shil context to create an override alarm object
    singleton.dummyContext.reset()
    singleton.overrideAlarm = AlarmEntity.mr_create(in: singleton.dummyContext)
    singleton.overrideAlarm!.applyTimePresenter(timePresenter)

    // Now we have to figure out what the next time that this
    // alarm would go off at.
    // Match on time
    let rawTime = timePresenter.calculatedTime()!
    let matchingComponents = NSDateComponents()
    matchingComponents.hour = rawTime.hour24
    matchingComponents.minute = rawTime.minute
    let calendar = Calendar.current
    let nextTime = calendar.nextDate(
        after: Date(),
        matching: matchingComponents as DateComponents,
        matchingPolicy: .nextTime)
    
    let weekday = calendar.component(.weekday, from: nextTime!)
    singleton.overrideAlarm!.weekday = weekday

    updateAlarmHelper()
  }

  // Clear out the override alarm
  class func clearOverrideAlarm() {
    NSLog("Clearing alarm override")
    singleton.overrideAlarm = nil
    updateAlarmHelper()
  }

  // True if the the current alarm is an override
  class func isOverridden() -> Bool {
    return singleton.overrideAlarm != nil
  }

  // Update the alarm helper with the impending alarm
  // AlarmHelper is idempotent, so it's alright to spam this function.
  // In practice, this function should be called anytime there is
  // a meaninful change to the persistence layer of alarms, ie. if
  // a user changes an alarm.
  class func updateAlarmHelper() {
    // If we have an override, use that
    if singleton.overrideAlarm != nil {
      AlarmHelper.setAlarm(singleton.overrideAlarm)
    } else {
      // check the schedule and activate the next alarm
      AlarmHelper.setAlarm(nextScheduledAlarm())
    }
  }

  // Get the next scheduled alarm time
  class func nextScheduledAlarm() -> AlarmEntity {
    // Get all of the known alarms
    let alarms = AlarmEntity.mr_findAll() as! [AlarmEntity]
    // Get an array of upcoming alarms, impending first
    let activeAlarms = alarms.filter({
      (alarm: AlarmEntity) -> Bool in
      // Filter out alarms without upcoming times
      alarm.nextAlarmTime() != nil
    }).sorted(by: {
      (a: AlarmEntity, b: AlarmEntity) -> Bool in
      // Sort them by who has the most impending time
      a.nextAlarmTime()!.compare(b.nextAlarmTime()! as Date) == ComparisonResult.orderedAscending
    })

    return activeAlarms.first!
  }

  // If we don't have any alarms in the system, create
  // initial, default alarms.
  class func createInitialAlarms() {
    AlarmEntity.DayOfWeek.allValues.map {
      (dayOfWeekEnum: AlarmEntity.DayOfWeek) -> () in

      let existingAlarmEntity = AlarmEntity.mr_findFirst(byAttribute: "dayOfWeek", withValue: dayOfWeekEnum.rawValue) 

      // If it's nil, we need to create it
      if existingAlarmEntity == nil {
        let newAlarmEntity = AlarmEntity.mr_createEntity()!
        newAlarmEntity.dayOfWeekEnum = dayOfWeekEnum
        newAlarmEntity.alarmTypeEnum = .Time
        newAlarmEntity.setValue(true, forKey: "enabled")
        newAlarmEntity.hour = 7
        newAlarmEntity.minute = 0
      }
    }
    // Save newly created records
    NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
  }

  // Get alarms in Sunday -> Saturday order
  class func loadAlarmsOrdered() -> [AlarmEntity] {
    let alarms = AlarmEntity.mr_findAll() as! [AlarmEntity]
    // Sort them by day of week
    return alarms.sorted {
      (a: AlarmEntity, b: AlarmEntity) -> Bool in
      a.weekday < b.weekday
    }
  }
}
