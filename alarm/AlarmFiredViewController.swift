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

  let awakeButtonWidth = CGFloat(160)
  let awakeButtonFontColor = UIColor.whiteColor()
  let awakeButtonCircleColor = UIColor(white: 0.0, alpha: 0.5)

  var delegate: AlarmFiredViewDelegate!
  var backgroundView: UIImageView!
  var awakeButtonCircleView: ButtonCircleView!
  

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

    addAwakeButton()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    backgroundView.alpha = CGFloat(0.6)
    backgroundView.frame = self.view.frame
    backgroundView.center = self.view.center
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // The user has hit the "awake" button
  func deactivateAlarm() {
    cancelAlarmSequence()
  }


  /* Private */

  // Add our awake button
  private func addAwakeButton() {
    //activationButtonCircleView
    // 107 277
    // 100 100
    if awakeButtonCircleView == nil {
      awakeButtonCircleView = ButtonCircleView(
        frame: CGRectMake(
          view.center.x - awakeButtonWidth / 2,
          view.frame.height * 0.65 - awakeButtonWidth / 2,
          awakeButtonWidth,
          awakeButtonWidth
        )
      )
      awakeButtonCircleView.labelText = "I'm awake"
      awakeButtonCircleView.color = awakeButtonFontColor
      awakeButtonCircleView.circleColor = awakeButtonCircleColor
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "deactivateAlarm")
      awakeButtonCircleView.addGestureRecognizer(tapRecognizer)
      view.addSubview(awakeButtonCircleView)
    }
  }

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
