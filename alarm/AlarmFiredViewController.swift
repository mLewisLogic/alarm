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
  var backgroundView: UIImageView!
  
  @IBOutlet weak var stopAlarmButton: UIButton!
  
  

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    startAlarmSequence()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let backgroundImage = UIImage(named: "old-watches.png")
    backgroundView = UIImageView(image: backgroundImage)
    self.view.insertSubview(backgroundView, atIndex: 0)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    backgroundView.alpha = CGFloat(0.6)
    backgroundView.frame = self.view.frame
    backgroundView.center = self.view.center
    
    stopAlarmButton.backgroundColor = UIColor.lightGrayColor()
    stopAlarmButton.layer.cornerRadius = 12.0
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
