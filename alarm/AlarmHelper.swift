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

class AlarmHelper: NSObject {

  var activeAlarm: AlarmEntity?
  var activeTimer: NSTimer?

  override init() {
    super.init()
  }

  // Create and hold onto a singleton instance of this class
  class var singleton: AlarmHelper {
    return _alarmHelper
  }


  /* Public interface */

  // Set the active alarm
  class func setAlarm(alarm: AlarmEntity?) {
    singleton.setAlarm(alarm)
  }

  // Activate the currently set alarm
  // This means starting the timer
  class func activateAlarm() {
    singleton.activateAlarm()
  }

  // Deactivate the alarm if it's running
  class func deactivateAlarm() {
    singleton.deactivateAlarm()
  }


  /* Event handlers */

  // Alarm activation handler
  func alarmFired(timer: NSTimer) {
    NSLog("Triggering alarmFired notification")
    NSNotificationCenter().postNotificationName("AlarmFired", object: activeAlarm)
  }


  /* Private */

  private func setAlarm(alarm: AlarmEntity?) {
    // If this is the same alarm that is already active, break.
    if alarm == activeAlarm {
      return
    }

    // Store our new alarm
    activeAlarm = alarm

    // deactivate any existing alarm
    deactivateAlarm()
  }

  // If we have an alarm set, activate it
  // Returns true if an alarm was activated
  private func activateAlarm() -> Bool {
    // Make sure any existing one is deactivated
    deactivateAlarm()

    // If we have a current alarm, activate it
    if let unwrappedAlarm = activeAlarm {
      if let alarmTime = unwrappedAlarm.nextAlarmTime() {
        NSLog("Activating alarm: \(alarmTime)")
        // Calculate the number of seconds until the alarm time.
        let secondsUntilAlarm = alarmTime.timeIntervalSinceDate(NSDate())
        // Create a new timer using the new alarm
        NSLog(String(format: "Setting an alarm for %.0f seconds in the future.", secondsUntilAlarm))
        activeTimer = NSTimer.scheduledTimerWithTimeInterval(
          secondsUntilAlarm,
          target: self,
          selector: "alarmFired:",
          userInfo: nil,
          repeats: false
        )
        return true
      }
    }

    return false
  }

  private func deactivateAlarm() {
    // If there's an existing timer, kill it
    if let timer = activeTimer {
      NSLog("Deactivating existing alarm")
      timer.invalidate()
      activeTimer = nil
    }
  }
}
