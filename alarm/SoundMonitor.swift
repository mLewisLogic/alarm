//
//  SoundMonitor.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import Foundation


// Monitor the sound levels of the environment. We can look for
// intesity spikes caused by the user moving around.


protocol SoundMonitorDelegate {
  func receiveSoundMonitorData(intensity: Double)
}

class SoundMonitor: NSObject, AVAudioRecorderDelegate {

  let recordSettings = [
    AVFormatIDKey: kAudioFormatAppleLossless,
    AVEncoderAudioQualityKey : AVAudioQuality.Min.rawValue,
    AVEncoderBitRateKey : 64000,
    AVNumberOfChannelsKey: 1,
    AVSampleRateKey : 44100.0,
  ]
  // We don't need to save the recorded sound. We just
  // want to monitor it's levels as it's being recorded.
  let soundFileURL = NSURL(fileURLWithPath: "/dev/null")
  let recorder: AVAudioRecorder

  // A periodic time checks levels
  var timerPeriod = NSTimeInterval(5.0) // seconds
  var meterTimer: NSTimer?

  // Feed the delegate our raw data
  var delegate: SoundMonitorDelegate!

  override init() {
    var error: NSError?
    recorder = AVAudioRecorder(
      URL: soundFileURL!,
      settings: recordSettings,
      error: &error
    )

    super.init()

    if let e = error {
      NSLog(e.description)
    } else {
      recorder.delegate = self
      recorder.meteringEnabled = true
    }
  }

  class func requestPermissionIfNeeded() {
    AVAudioSession.sharedInstance().requestRecordPermission({
      (granted: Bool)-> Void in
      // handle as needed
    })
  }


  /* Public interface */
  func startRecording() {
    NSLog("SoundMonitor: startRecording()")
    // Clean up any residual timer
    invalidateTimer()

    // Activate the AVAudioSession
    var error: NSError?
    AVAudioSession.sharedInstance().setActive(
      true,
      error: &error
    )
    if let e = error {
      NSLog(e.description)
    }

    // Start recording
    recorder.record()

    // Set up periodic
    meterTimer = NSTimer.scheduledTimerWithTimeInterval(
      timerPeriod, // seconds
      target: self,
      selector: "updateAudioMeter:",
      userInfo: nil,
      repeats: true
    )
  }

  func stopRecording() {
    invalidateTimer()
    recorder.stop()
  }


  /* Delegate and event handling */
  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
    NSLog("finished recording \(flag)")
  }

  func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
    NSLog("\(error.localizedDescription)")
  }

  func updateAudioMeter(timer: NSTimer) {
    if recorder.recording {
      recorder.updateMeters()
      delegate.receiveSoundMonitorData(Double(recorder.peakPowerForChannel(0)))
    }
  }


  /* Private functions */
  private func invalidateTimer() {
    if let timer = meterTimer {
      timer.invalidate()
      meterTimer = nil
    }
  }

  // Returns true if we need to ask for microphone permission
  private func needsPermission() -> Bool {
    return AVAudioSessionRecordPermission.Undetermined == AVAudioSession.sharedInstance().recordPermission()
  }
}
