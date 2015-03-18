//
//  SoundMonitorHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import Foundation


// Stash a singleton global instance
private let _soundMonitorHelper = SoundMonitorHelper()

class SoundMonitorHelper: NSObject, AVAudioRecorderDelegate {
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
  let session: AVAudioSession = AVAudioSession.sharedInstance()
  let recorder: AVAudioRecorder

  // A periodic time checks levels
  var meterTimer: NSTimer?

  override init() {
    var sessionError: NSError?
    session = AVAudioSession.sharedInstance()
    session.setCategory(AVAudioSessionCategoryRecord, error: &sessionError)
    if let e = sessionError {
      println(e.localizedDescription)
    }

    var recorderError: NSError?
    recorder = AVAudioRecorder(
      URL: soundFileURL!,
      settings: recordSettings,
      error: &recorderError
    )

    super.init()

    if let e = recorderError {
      println(e.localizedDescription)
    } else {
      recorder.delegate = self
      recorder.meteringEnabled = true
    }
  }

  // Create and hold onto a singleton instance of this class
  class var singleton: SoundMonitorHelper {
    return _soundMonitorHelper
  }

  class func requestPermissionIfNeeded() {
    singleton.session.requestRecordPermission({
      (granted: Bool)-> Void in

    })
  }

  class func startRecording() {
    singleton.recorder.record()

    singleton.meterTimer = NSTimer.scheduledTimerWithTimeInterval(
      5.0, // seconds
      target: singleton,
      selector: "updateAudioMeter:",
      userInfo: nil,
      repeats: true
    )
  }

  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
    NSLog("finished recording \(flag)")
  }

  func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
    NSLog("\(error.localizedDescription)")
  }

  func updateAudioMeter(timer: NSTimer) {
    if recorder.recording {
      recorder.updateMeters()
      var apc0  = recorder.averagePowerForChannel(0)
      var peak0 = recorder.peakPowerForChannel(0)
    }
  }

  // Returns true if we need to ask for microphone permission
  private func needsPermission() -> Bool {
    return AVAudioSessionRecordPermission.Undetermined == session.recordPermission()
  }
}
