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

  var blurPresenter: BlurPresenter!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up a default TimePresenter
    // TODO: Make this real, based upon active alarms
    currentTime = TimePresenter(hour24: 7, minute: 30)
    updateDisplayTime()

    // Do any additional setup after loading the view.
    blurPresenter = BlurPresenter(parent: self.view)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func timeChangeSelected(sender: UIButton) {
    blurPresenter.showBlur()

    // Create a new AlarmView overlaying
    var alarmViewController = AlarmViewController(
      nibName: "AlarmViewController",
      bundle: nil
    )
    // Assign it's delegate as this view
    alarmViewController.delegate = self
    alarmViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    alarmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

    // Let the picker know what it should have selected
    alarmViewController.startingTimePresenter = currentTime

    // Present the new controller
    presentViewController(alarmViewController, animated: true, completion: nil)
  }

  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    currentTime = time
    updateDisplayTime()
  }


  /* Private */

  // Update the displayed time
  private func updateDisplayTime() {
  }
}
