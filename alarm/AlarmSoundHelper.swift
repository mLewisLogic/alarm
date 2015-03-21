//
//  AlarmSoundHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import Foundation


// Stash a singleton global instance
private let _alarmSoundHelper = AlarmSoundHelper()

class AlarmSoundHelper: NSObject {

  let alertSound = NSURL(
    fileURLWithPath: NSBundle.mainBundle().pathForResource("alarm", ofType: "m4a")!
  )
  let player: AVAudioPlayer


  override init() {
    var error: NSError?
    player = AVAudioPlayer(
      contentsOfURL: alertSound,
      error: &error
    )
    if let e = error {
      NSLog("AlarmSoundHelper error: \(e.description)")
    }

    // Repeat it for a long time, until cancelled
    player.numberOfLoops = 100

    super.init()

  }

  // Create and hold onto a singleton instance of this class
  class var singleton: AlarmSoundHelper {
    return _alarmSoundHelper
  }

  class func startPlaying() {
    singleton.player.currentTime = 0
    singleton.player.prepareToPlay()
    singleton.player.play()
  }

  class func stopPlaying() {
    singleton.player.stop()
  }
}
