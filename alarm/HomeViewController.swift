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

  var currentTime: TimeElement!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  @IBAction func timeChangeSelected(sender: UIButton) {
    // Add a blur subview
    let blurEffect = UIBlurEffect(style: .Dark)
    var blurEffectView = UIVisualEffectView(effect: blurEffect) as UIVisualEffectView
    blurEffectView.frame = self.view.bounds
    self.view.addSubview(blurEffectView)

    // Add a vibrancy subview
    var vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
    var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    vibrancyEffectView.frame = blurEffectView.frame
    blurEffectView.addSubview(vibrancyEffectView)

    // Create a new AlarmView overlaying
    var alarmViewController = AlarmViewController(
      nibName: "AlarmViewController",
      bundle: nil
    )
    // Assign it's delegate as this view
    alarmViewController.delegate = self
    //alarmViewController.view.bounds = self.view.bounds
    alarmViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    alarmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

    // Transition to the overlay view
    //vibrancyEffectView.addSubview(alarmViewController.view)

    // Present the new controller
    //addChildViewController(alarmViewController)
    presentViewController(alarmViewController, animated: true, completion: nil)
  }

  // Delegate callback from the time picker
  func timeSelected(time: TimeElement) {
    currentTime = time
    updateDisplayTime()
  }

  // Update the displayed time
  private func updateDisplayTime() {
  }
}
