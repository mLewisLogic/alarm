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
  func receiveSoundMonitorData(_ intensity: Double)
}

class SoundMonitor: NSObject, AVAudioRecorderDelegate {

  let recordSettings = [
    AVFormatIDKey: kAudioFormatAppleLossless,
    AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue,
    AVEncoderBitRateKey : 64000,
    AVNumberOfChannelsKey: 1,
    AVSampleRateKey : 44100.0,
  ] as [String : Any]
  // We don't need to save the recorded sound. We just
  // want to monitor it's levels as it's being recorded.
  let soundFileURL = URL(fileURLWithPath: "/dev/null")
  let recorder: AVAudioRecorder

  // A periodic time checks levels
  var timerPeriod = TimeInterval(5.0) // seconds
  var meterTimer: Timer?

  // Feed the delegate our raw data
  var delegate: SoundMonitorDelegate!

  override init() {
    recorder = try! AVAudioRecorder(
        url: soundFileURL,
        settings: recordSettings as [String : Any]
    )
    
    super.init()
    
    recorder.delegate = self
    recorder.isMeteringEnabled = true
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
    do {
        try AVAudioSession.sharedInstance().setActive(true)
    } catch let error {
        NSLog(error.localizedDescription)
    }

    // Start recording
    recorder.record()

    // Set up periodic
    meterTimer = Timer.scheduledTimer(
        timeInterval: timerPeriod, // seconds
      target: self,
      selector: #selector(updateAudioMeter),
      userInfo: nil,
      repeats: true
    )
  }

  func stopRecording() {
    invalidateTimer()
    recorder.stop()
  }


  /* Delegate and event handling */
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    NSLog("finished recording \(flag)")
  }

  func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
    NSLog("\(String(describing: error?.localizedDescription))")
  }

  func updateAudioMeter(_ timer: Timer) {
    if (recorder.isRecording) {
      recorder.updateMeters()
      delegate.receiveSoundMonitorData(Double(recorder.peakPower(forChannel: 0)))
    }
  }


  /* Private functions */
  fileprivate func invalidateTimer() {
    if let timer = meterTimer {
      timer.invalidate()
      meterTimer = nil
    }
  }

  // Returns true if we need to ask for microphone permission
  fileprivate func needsPermission() -> Bool {
    return AVAudioSessionRecordPermission.undetermined == AVAudioSession.sharedInstance().recordPermission()
  }
}
