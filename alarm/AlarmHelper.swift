//
//  AlarmHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

// This class is specifically responsible for keeping track of
// the active alarm. It will ensure that the upcoming alarm is
// enabled if it needs to be.
// It is also responsible for managing outstanding alarms, including
// cancelling them if the active alarm changes.

// Stash a singleton global instance
private let _alarmHelper = AlarmHelper()

class AlarmHelper {

  var activeAlarm: AlarmEntity?
  var activeTimer: NSTimer?

  init() {
  }

  // Create and hold onto a singleton instance of this class
  class var singleton: AlarmHelper {
    return _alarmHelper
  }


  /* Public interface */

  // Set the active alarm
  class func setAlarm(alarm: AlarmEntity) {
    singleton.setAlarm(alarm)
  }


  /* Private */

  private func setAlarm(alarm: AlarmEntity) {
    activeAlarm = alarm
    // If there's an existing timer, kill it
    if let timer = activeTimer {
      timer.invalidate()
    }

    // Create a new timer using the new alarm
  }
}
