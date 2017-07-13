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

class SleepQualityMonitor: SoundMonitorDelegate, MotionMonitorDelegate {

  var delegate: SleepQualityMonitorDelegate!

  /* Sound config */
  let soundMonitor: SoundMonitor
  // Keep track of time and intensity of sound
  var soundTimeData: [TimeInterval] = []
  var soundIntensityData: [Double] = []
  let soundDataMutex = NSObject()
  // Time-stamps where we think we heard motion
  var soundEvents: [TimeInterval] = []

  let SOUND_CALCULATION_TIME_WINDOW: TimeInterval = 10.0 * 60.0 // 10 minutes (in seconds)
  let SOUND_CALCULATION_PERIOD: TimeInterval = 1.0 // seconds
  let SOUND_CALCULATION_INDEX_WINDOW: Int


  /* Motion config */
  let motionMonitor: MotionMonitor
  // Keep track of time and intensity of movement
  var motionTimeData: [TimeInterval] = []
  var motionIntensityData: [Double] = []
  let motionDataMutex = NSObject()
  // Time-stamps where we think we saw motion
  var motionEvents: [TimeInterval] = []

  let MOTION_CALCULATION_TIME_WINDOW: TimeInterval = 10.0 * 60.0 // 10 minutes (in seconds)
  let MOTION_SPIKE_SCALAR_THRESHOLD = 5.0 // 5x mean acceleration

  /* Data pruning job */
  var dataPruningTimer: Timer?
  let DATA_PRUNING_PERIOD = 60.0 // seconds


  init() {
    // The number of items in the sound data to look at when calculating
    SOUND_CALCULATION_INDEX_WINDOW =
      Int(SOUND_CALCULATION_TIME_WINDOW / SOUND_CALCULATION_PERIOD)

    // Set up our sound monitor
    soundMonitor = SoundMonitor()
    soundMonitor.timerPeriod = SOUND_CALCULATION_PERIOD

    // Set up our motion monitor
    motionMonitor = MotionMonitor()

    // Set up the delegates
    soundMonitor.delegate = self
    motionMonitor.delegate = self
  }


  /* Public interface */
  func startMonitoring() {
    NSLog("Starting sleep quality monitoring")
    // Make sure we're stopped
    stopMonitoring()

    // Clear out the data
    with_mutex(soundDataMutex) {
      self.soundTimeData = []
      self.soundIntensityData = []
      self.soundEvents = []
    }
    with_mutex(motionDataMutex) {
      self.motionTimeData = []
      self.motionIntensityData = []
      self.motionEvents = []
    }

    // Start up the monitoring
    soundMonitor.startRecording()
    motionMonitor.startMonitoring()
  }

  func stopMonitoring() {
    soundMonitor.stopRecording()
    motionMonitor.stopMonitoring()
  }


  /* Delegate handling */

  // Handle receiving sound monitor data
  func receiveSoundMonitorData(_ intensity: Double) {
    // Perform this under a mutex to avoid data corruption
    with_mutex(soundDataMutex) {
      // Stash the timestamp and data
      self.soundTimeData.append(NSDate().timeIntervalSince1970)
      self.soundIntensityData.append(intensity)
    }

    // We have new data, so check to see if we should wake up
    checkAndNotify()
  }

  // Handle receiving motion monitor data
  func receiveMotionMonitorData(_ intensity: Double) {
    // Perform this under a mutex to avoid data corruption
    with_mutex(motionDataMutex) {
      // Stash the timestamp and data
      self.motionTimeData.append(NSDate().timeIntervalSince1970)
      self.motionIntensityData.append(intensity)
    }

    // See if this latest data point is considered a motion "event"
    self.checkLatestMotionDataPoint()

    // We have new data, so check to see if we should wake up
    checkAndNotify()
  }


  /* Event handling */
  // Prune old data in a safe way
  // This should be called periodically to make sure we don't blow up memory.
  @objc func pruneData(_ timer: Timer) {
    // Perform this under a mutex to avoid data corruption
    with_mutex(soundDataMutex) {
      let thresholdTime = NSDate().timeIntervalSince1970 - self.SOUND_CALCULATION_TIME_WINDOW
      let numElementsToKeep = self.soundTimeData.filter({ $0 >= thresholdTime }).count
      let firstElement = self.soundTimeData.count - numElementsToKeep
      let lastElement = self.soundTimeData.count - 1
      self.soundTimeData = Array(self.soundTimeData[firstElement...lastElement])
      self.soundIntensityData = Array(self.soundIntensityData[firstElement...lastElement])
    }

    // Perform this under a mutex to avoid data corruption
    with_mutex(motionDataMutex) {
      let thresholdTime = NSDate().timeIntervalSince1970 - self.MOTION_CALCULATION_TIME_WINDOW
      let numElementsToKeep = self.motionTimeData.filter({ $0 >= thresholdTime }).count
      let firstElement = self.motionTimeData.count - numElementsToKeep
      let lastElement = self.motionTimeData.count - 1
      self.motionTimeData = Array(self.motionTimeData[firstElement...lastElement])
      self.motionIntensityData = Array(self.motionIntensityData[firstElement...lastElement])
    }
  }



  /* Private functions */

  // Basic locking functionality for the arrays
  func with_mutex(_ mutex: AnyObject, closure: () -> ()) {
    objc_sync_enter(mutex)
    closure()
    objc_sync_exit(mutex)
  }

  // Check if the microphone data thinks we should wake up
  // We're actually going to be checking to see if the user is falling
  // back asleep. This is working on the assumption that if the user is
  // naturally waking up, we should let them. We only want to activate
  // the alarm early if the user is in danger of falling back into deep
  // sleep before their alarm goes off.
  fileprivate func checkAndNotify() {
    if isUserFallingBackAsleep() {
      delegate.userShouldWakeUp()
    }
  }

  // Determine if the user is waking up right now
  fileprivate func isUserFallingBackAsleep() -> Bool {
    //let soundSlope = soundMonitorSlope()
    //NSLog("Sound monitor slope: \(soundSlope)")

    let tenMinutesAgo: TimeInterval = NSDate().timeIntervalSince1970 - 10.0 * 60.0
    let twentyMinutesAgo: TimeInterval = tenMinutesAgo - 10.0 * 60.0

    var isMovingLess = false
    // Perform this under a mutex to avoid bad reads
    with_mutex(motionDataMutex) {
      // Are there fewer motion events in the past 10 minutes than
      // in the 10 minutes prior?
      let numEventsInLastTenMinutes = self.motionEvents.filter({
        tenMinutesAgo < $0
      }).count
      let numEventsInLastTwentyMinutes = self.motionEvents.filter({
        twentyMinutesAgo < $0 && $0 < tenMinutesAgo
      }).count
      isMovingLess = numEventsInLastTenMinutes < numEventsInLastTwentyMinutes
    }

    return isMovingLess
  }

  // Calculate a slope for the sound data
  fileprivate func soundMonitorSlope() -> Double {
    // Don't even bother
    if soundIntensityData.count > SOUND_CALCULATION_INDEX_WINDOW {
      // Get a slice of the `SOUND_CALCULATION_INDEX_WINDOW` most recent rows
      let recentSoundIntensityData = Array(soundIntensityData[
        soundIntensityData.count-SOUND_CALCULATION_INDEX_WINDOW..<soundIntensityData.count
      ])
      return LinearRegression.slope(recentSoundIntensityData, y: soundTimeData)
    } else {
      // Not enough data points. No slope.
      return 0.0
    }
  }

  // Did the last event exceed our mean by a scalar threshold?
  fileprivate func checkLatestMotionDataPoint() {
    // Perform this under a mutex to avoid bad reads
    with_mutex(motionDataMutex) {
      // This is inefficient to do every time. The summation should be cached.
      let count = Double(self.motionIntensityData.count)
      // Need to have at least 2 data points
      if count >= 2 {
        let mean = self.motionIntensityData.reduce(0.0, +) / count

        let latestIntensity = self.motionIntensityData[self.motionIntensityData.count-1]
        let previousIntensity = self.motionIntensityData[self.motionIntensityData.count-2]
        // If the latest reading is much higer than the mean and
        // is very different from the previous, save it as an event.
        if latestIntensity > (mean * self.MOTION_SPIKE_SCALAR_THRESHOLD) &&
            (latestIntensity - previousIntensity) > mean {
          NSLog("Motion event: intensity=\(latestIntensity), mean=\(mean)")
          self.motionEvents.append(self.motionTimeData.last!)
        }
      }
    }
  }

  // Kicks off a periodic timer to prune data that's outside of our window
  fileprivate func startDataPruningTimer() {
    invalidateDataPruningTimer()
    dataPruningTimer = Timer.scheduledTimer(
        timeInterval: DATA_PRUNING_PERIOD,
      target: self,
      selector: #selector(pruneData),
      userInfo: nil,
      repeats: true
    )
  }

  // Kill existing timer if it exists
  fileprivate func invalidateDataPruningTimer() {
    if let timer = dataPruningTimer {
      timer.invalidate()
      dataPruningTimer = nil
    }
  }
}
