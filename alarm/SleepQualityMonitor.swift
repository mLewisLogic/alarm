//
//  SleepQualityMonitor.swift
//  alarm
//
//  Created by Michael Lewis on 3/21/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

/**
 * The SleepQualityMonitor is responsible for running the sensor
 * helpers, running calculations on their data, and determining
 * the quality of the user's sleep based upon them.
 * 
 * In the most practical sense, this class is responsible for
 * notifying it's delegate if it thinks that the user should be
 * woken up. The AlarmHelper will integrate that into the alarm
 * logic to determine if we want to act on that information.
 * ie, is it during the 30-minute pre-alarm phase?
 */

protocol SleepQualityMonitorDelegate {
  func userShouldWakeUp()
}

class SleepQualityMonitor: SoundMonitorHelperDelegate {

  var delegate: SleepQualityMonitorDelegate!

  let soundMonitor: SoundMonitorHelper

  var soundData: [Double] = []
  let SOUND_CALCULATION_TIME_WINDOW = 1.0 * 60.0 // 10 minutes (in seconds)
  let SOUND_CALCULATION_PERIOD = 5.0 // seconds
  let SOUND_CALCULATION_INDEX_WINDOW: Int

  init() {
    // The number of rows in the array to look at when calculating
    SOUND_CALCULATION_INDEX_WINDOW =
      Int(SOUND_CALCULATION_TIME_WINDOW / SOUND_CALCULATION_PERIOD)
    // Set up our sound monitor
    soundMonitor = SoundMonitorHelper()
    soundMonitor.timerPeriod = SOUND_CALCULATION_PERIOD
    soundMonitor.delegate = self
  }

  /* Public interface */
  func startMonitoring() {
    soundData = []
    soundMonitor.startRecording()
  }

  func stopMonitoring() {
    soundMonitor.stopRecording()
  }


  /* Delegate handling */
  func receiveSoundMonitorData(intensity: Float) {
    NSLog("sound data: \(intensity)")
    // Stash the data
    soundData.append(Double(intensity))

    // We have new data, so check to see if we should wake up
    checkAndNotify()
  }

  /* Private functions */
  // Check if the microphone data thinks we should wake up
  // We're actually going to be checking to see if the user is falling
  // back asleep. This is working on the assumption that if the user is
  // naturally waking up, we should let them. We only want to activate
  // the alarm early if the user is in danger of falling back into deep
  // sleep before their alarm goes off.
  private func checkAndNotify() {
    if isUserWakingUp() {
      delegate.userShouldWakeUp()
    }
  }

  private func isUserWakingUp() -> Bool {
    let soundSlope = soundMonitorSlope()
    NSLog("Sound monitor slope: \(soundSlope)")

    return false
  }

  private func soundMonitorSlope() -> Double {
    // Don't even bother
    if soundData.count > SOUND_CALCULATION_INDEX_WINDOW {
      // Get a slice of the `SOUND_CALCULATION_INDEX_WINDOW` most recent rows
      let recentSoundData = Array(soundData[
        soundData.count-SOUND_CALCULATION_INDEX_WINDOW..<soundData.count
      ])
      let timeData = (0...SOUND_CALCULATION_INDEX_WINDOW-1).map({
        (timeIndex: Int) -> Double in
        return Double(timeIndex) * self.SOUND_CALCULATION_PERIOD
      })
      return LinearRegression.slope(recentSoundData, y: timeData)
    } else {
      return 0.0 // no slope
    }
  }

}