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
    AlarmSoundHelper.stopPlaying()
    delegate.dismissAlarmFiredView()
  }

  private func playWakeupSound() {
    AlarmSoundHelper.startPlaying()
  }
}
