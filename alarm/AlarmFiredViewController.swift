//
//  AlarmActivationViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/21/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import UIKit

class AlarmFiredViewController: UIViewController {

  var delegate: AlarmFiredViewDelegate!
  private var audioPlayer: AVAudioPlayer?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    startAlarmSequence()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // The user has hit the "disable" button
  @IBAction func deactivateAlarm(sender: UIButton) {
    cancelAlarmSequence()
  }


  /* Private */

  // Let's wake the user up!
  func startAlarmSequence() {
    playWakeupSound()
  }

  // Cancel the alarm
  func cancelAlarmSequence() {
    audioPlayer?.stop()
    audioPlayer = nil
    delegate.dismissAlarmFiredView()
  }

  private func playWakeupSound() {
    var alertSound = NSURL(
      fileURLWithPath: NSBundle.mainBundle().pathForResource("alarm", ofType: "m4a")!
    )

    // Removed deprecated use of AVAudioSessionDelegate protocol
    AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
    AVAudioSession.sharedInstance().setActive(true, error: nil)

    var error:NSError?
    audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
    audioPlayer!.prepareToPlay()
    audioPlayer!.play()
  }
}
