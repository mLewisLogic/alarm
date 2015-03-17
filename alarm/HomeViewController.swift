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
  var settingsModal: SettingsModalViewController!
  
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
  
  override func viewWillAppear(animated: Bool) {
    addSettingsModal()
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
  
  private func addSettingsModal() {
    settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
    self.addChildViewController(settingsModal)
    settingsModal.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    settingsModal.openPosition = self.view.center.y
    settingsModal.view.frame = CGRectMake((self.view.frame.size.width - (self.view.frame.size.width * 0.8)) / 2, self.view.frame.size.height - settingsModal.alarmSwitch.frame.height - 25, self.view.frame.size.width * 0.8, self.view.frame.size.height * 0.8)
    settingsModal.view.layer.cornerRadius = 12.0
    settingsModal.view.layer.masksToBounds = true
    settingsModal.view.clipsToBounds = false
    
    settingsModal.closedPosition = settingsModal.view.center.y
    
    applyPlainShadow(settingsModal.view)

    self.view.addSubview(settingsModal.view)
    settingsModal.didMoveToParentViewController(self)
  }
  
  private func applyPlainShadow(view: UIView) {
    var layer = view.layer
    
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSize(width: 0, height: 10)
    layer.shadowOpacity = 0.4
    layer.shadowRadius = 5
  }
}
