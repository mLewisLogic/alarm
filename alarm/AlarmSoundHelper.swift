
//
//  AlarmSoundHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import Foundation


class AlarmSoundHelper: NSObject {
    
  // Stash a singleton global instance
  fileprivate static let _alarmSoundHelper = AlarmSoundHelper()

  let VOLUME_INITIAL: Float = 0.20 // start at 20%
  let VOLUME_RAMP_UP_STEP: Float = 0.01 // 1% at a time
  let VOLUME_RAMP_UP_TIME: Float = 60.0 // seconds
  let VOLUME_RAMP_DOWN_STEP: Float = 0.05 // 5% at a time
  let VOLUME_RAMP_DOWN_TIME: Float = 3.0 // seconds

  let FIRST_VIBRATION_AT: Float = 60.0 // seconds
  let VIBRATION_URGENCY: Float = 1.0 / 1.25 // Next vibe arrives 25% faster


  let alertSound = URL(
    fileURLWithPath: Bundle.main.path(forResource: "alarm", ofType: "m4a")!
  )
  let player: AVAudioPlayer

  // The volumeTimer is responsible for ramping the volume up and down
  var volumeTimer: Timer?
  var vibrationTimer: Timer?

  // How long we're waiting until the next vibration
  var currentVibrationWait: Float = 0.0

  override init() {
    player = try! AVAudioPlayer(contentsOf: alertSound)
    super.init()
  }

  // Create and hold onto a singleton instance of this class
  static var singleton: AlarmSoundHelper {
    return ._alarmSoundHelper
  }

  /* Public interface */
  static func startPlaying() {
    singleton._startPlaying()
  }

  static func stopPlaying() {
    singleton._stopPlaying()
  }


  /* Instance functions */
  // Start playing the sound, and ramp up the volume
  func _startPlaying() {
    player.volume = VOLUME_INITIAL
    player.currentTime = 0
    player.numberOfLoops = 100
    player.prepareToPlay()
    player.play()
    rampUpVolume()
    activateVibrationRampup()
  }

  // Ramp the volume down to zero.
  // When it reaches zero, stop the player.
  func _stopPlaying() {
    rampDownVolumeToStop()
    invalidateVibrationTimer()
  }


  /* Event handlers */
  // Called by the volumeTimer to slowly increase volume
  func increaseVolumeOneNotch() {
    player.volume += VOLUME_RAMP_UP_STEP

    // If we've reached full volume, stop the timer
    if player.volume >= 1.0 {
      NSLog("Volume at 100%")
      invalidateVolumeTimer()
      // For sanity, make sure volume is not above 1.0
      player.volume = 1.0
    }
  }

  // Called by the volumeTimer to slowly decrease volume
  func decreaseVolumeOneNotchToStop() {
    player.volume -= VOLUME_RAMP_DOWN_STEP

    // If we've reached zero volume, stop the player and the timer
    if player.volume <= 0.0 {
      NSLog("Volume at 0%")
      invalidateVolumeTimer()
      // For sanity, make sure volume is not below 0.0
      player.volume = 0.0
      // Stop the player
      player.stop()
    }
  }

  // Trigger a vibration and schedule the next one
  func triggerVibration() {
    NSLog("vibe")
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

    invalidateVibrationTimer()

    currentVibrationWait *= VIBRATION_URGENCY
    // Cap it at one vibration per 5 seconds
    if currentVibrationWait < 5.0 {
      currentVibrationWait = 5.0
    }

    vibrationTimer = Timer.scheduledTimer(
        timeInterval: TimeInterval(currentVibrationWait), // seconds
      target: self,
      selector: #selector(triggerVibration),
      userInfo: nil,
      repeats: false
    )
  }
}

fileprivate extension AlarmSoundHelper {
    /* Private functions */
    
    // If there's an old volume timer, invalidate it
    func invalidateVolumeTimer() {
        if let timer = volumeTimer {
            timer.invalidate()
            volumeTimer = nil
        }
    }
    
    // If there's an old vibration timer, invalidate it
    func invalidateVibrationTimer() {
        if let timer = vibrationTimer {
            timer.invalidate()
            vibrationTimer = nil
        }
    }
    
    func rampUpVolume() {
        invalidateVolumeTimer()
        
        // Set up a repeating timer that ramps up the player volume
        volumeTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(VOLUME_RAMP_UP_TIME * VOLUME_RAMP_UP_STEP), // seconds
            target: self,
            selector: #selector(increaseVolumeOneNotch),
            userInfo: nil,
            repeats: true
        )
    }
    
    func rampDownVolumeToStop() {
        invalidateVolumeTimer()
        
        // Set up a repeating timer that ramps up the player volume
        volumeTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(VOLUME_RAMP_DOWN_TIME * VOLUME_RAMP_DOWN_STEP), // seconds
            target: self,
            selector: #selector(decreaseVolumeOneNotchToStop),
            userInfo: nil,
            repeats: true
        )
    }
    
    // Vibration is not introduced until a ways into the alarm
    // It starts out slow and ramps up exponentially
    // Unhandled, it will get really annoying
    func activateVibrationRampup() {
        // Invalidate the existing timer
        invalidateVibrationTimer()
        
        // Reset our vibration wait
        currentVibrationWait = FIRST_VIBRATION_AT
        
        // Set up the timer for the first one. It's recursive for the rest.
        vibrationTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(currentVibrationWait), // seconds
            target: self,
            selector: #selector(triggerVibration),
            userInfo: nil,
            repeats: false
        )
    }
}
