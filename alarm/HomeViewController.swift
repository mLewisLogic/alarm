//
//  HomeViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/14/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit


protocol TimePickerManagerDelegate {
  func showTimePicker(pickerDelegate: TimePickerDelegate, time: TimePresenter)
  func dismissTimePicker()
}


class HomeViewController: UIViewController, TimePickerDelegate, TimePickerManagerDelegate {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var secondaryTimeLabel: UILabel!
  
  var currentTime: TimePresenter!

  var blurViewPresenter: BlurViewPresenter!
  var timePickerViewController: UIViewController?
  var settingsModal: SettingsModalViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up a default TimePresenter
    // TODO: Make this real, based upon active alarms
    currentTime = TimePresenter(hour24: 7, minute: 30)
    updateDisplayTime()

    // Set up our presenters for later use
    blurViewPresenter = BlurViewPresenter(parent: self.view)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
    addSettingsModal()
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func timeChangeSelected(sender: UIButton) {
    showTimePicker(self, time: currentTime)
  }

  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    currentTime = time
    updateDisplayTime()
    dismissTimePicker()
  }

  func showTimePicker(pickerDelegate: TimePickerDelegate, time: TimePresenter) {
    blurViewPresenter.showBlur()

    // Prepare and present the alarm picker controller
    timePickerViewController = TimePickerPresenter.preparePicker(pickerDelegate, time: time)
    presentViewController(
      timePickerViewController!,
      animated: true,
      completion: nil
    )
  }

  // Dismiss the previously created timePicker
  func dismissTimePicker() {
    // dismiss and kill the timePickerViewController
    timePickerViewController?.dismissViewControllerAnimated(true, completion: nil)
    timePickerViewController = nil
    blurViewPresenter.hideBlur()
  }
  
  /* Private */

  // Update the displayed time
  private func updateDisplayTime() {
    setBackgroundImage()
    // TODO: Implement label updates
  }
  
  private func addSettingsModal() {
    let modalWidthRatio = CGFloat(0.92)
    let modalHeightRatio = CGFloat(0.8)
    settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
    self.addChildViewController(settingsModal)
    settingsModal.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    settingsModal.openPosition = self.view.center.y
    settingsModal.view.frame = CGRectMake(
      (self.view.frame.size.width - (self.view.frame.size.width * modalWidthRatio)) / 2.0,
      self.view.frame.size.height - 50,
      self.view.frame.size.width * modalWidthRatio,
      self.view.frame.size.height * modalHeightRatio
    )
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
  
  private func setBackgroundImage() {
    let backgroundImageView = BackgroundImagePresenter(alarmTime: currentTime.calculatedTime()!)
    self.view.insertSubview(backgroundImageView.getImage(), atIndex: 0)
  }
}
