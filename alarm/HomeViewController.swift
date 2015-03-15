//
//  HomeViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/14/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, TimePickerDelegate {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var secondaryTimeLabel: UILabel!

  var currentTime: TimePresenter!

  var blurViewPresenter: BlurViewPresenter!
  var alarmPickerPresenter: AlarmPickerPresenter!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up a default TimePresenter
    // TODO: Make this real, based upon active alarms
    currentTime = TimePresenter(hour24: 7, minute: 30)
    updateDisplayTime()

    // Set up our presenters for later use
    blurViewPresenter = BlurViewPresenter(parent: self.view)
    alarmPickerPresenter = AlarmPickerPresenter(delegate: self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func timeChangeSelected(sender: UIButton) {
    blurViewPresenter.showBlur()

    // Prepare and present the alarm picker controller
    let timePickerViewController = alarmPickerPresenter.prepareAlarmPicker(currentTime)
    presentViewController(timePickerViewController, animated: true, completion: nil)
  }

  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    currentTime = time
    updateDisplayTime()
  }


  /* Private */

  // Update the displayed time
  private func updateDisplayTime() {
    // TODO: Implement me
  }
}
