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

class AlarmManager {

  // Update the alarm helper with the impending alarm
  // AlarmHelper is idempotent, so it's alright to spam this function.
  // In practice, this function should be called anytime there is
  // a meaninful change to the persistence layer of alarms, ie. if
  // a user changes an alarm.
  func updateAlarmHelper() {
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
      AlarmHelper.setAlarm(activeAlarms.first!)
    } else {
      AlarmHelper.setAlarm(nil)
    }
  }

}
