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

protocol AlarmFiredViewDelegate {
  func dismissAlarmFiredView()
}


class HomeViewController: UIViewController, TimePickerDelegate, TimePickerManagerDelegate, AlarmFiredViewDelegate {

  @IBOutlet weak var primaryTimeLabel: UILabel!
  @IBOutlet weak var secondaryTimeLabel: UILabel!
  @IBOutlet weak var overrideLabel: UILabel!

  var currentTime: TimePresenter!

  var blurViewPresenter: BlurViewPresenter!
  var timePickerViewController: UIViewController?
  var settingsModal: SettingsModalViewController!
  var backgroundImagePresenter: BackgroundImagePresenter!
  var backgroundImageView = UIImageView()
  var alarmFiredViewController: AlarmFiredViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Insert the background image in our view structure
    self.view.insertSubview(backgroundImageView, atIndex: 0)

    // Set up a default TimePresenter
    currentTime = TimePresenter(alarmEntity: AlarmManager.nextAlarm())
    // Set up our presenters for later use
    blurViewPresenter = BlurViewPresenter(parent: self.view)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)

    // Set the sizing for the background view
    backgroundImageView.frame = self.view.frame
    backgroundImagePresenter = BackgroundImagePresenter(alarmTime: currentTime.calculatedTime()!,
      imageView: backgroundImageView)
      
    updateDisplay()
    addSettingsModal()

    // If the next scheduled time changes, we want to overwrite our override
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "updateCurrentTime:",
      name: Notifications.NextScheduledAlarmChanged,
      object: nil
    )

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "activateAlarmFiredView:",
      name: Notifications.AlarmFired,
      object: nil
    )
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func timeChangeSelected(sender: UIButton) {
    showTimePicker(self, time: currentTime)
  }

  // Activate the time picker
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

  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    currentTime = time
    AlarmManager.setOverrideAlarm(time)
    dismissTimePicker()
  }

  // Dismiss the previously created timePicker
  func dismissTimePicker() {
    // dismiss and kill the timePickerViewController
    timePickerViewController?.dismissViewControllerAnimated(true, completion: nil)
    timePickerViewController = nil
    blurViewPresenter.hideBlur()
    updateDisplay()
  }

  // Allow the currently selected Home screen time to be updated
  func updateCurrentTime(notification: NSNotification) {
    let alarmEntity = notification.object as AlarmEntity!
    NSLog("updateCurrentTime: \(alarmEntity)")
    currentTime = TimePresenter(alarmEntity: alarmEntity)
    updateDisplay()
  }


  @IBAction func activateAlarm(sender: UIButton) {
    AlarmHelper.activateAlarm()
    // TODO: Update the UI to reflect the fact that an alarm is active
  }

  // The alarm has activated. Create the alarm activation view as a subview
  // and present it over the app.
  func activateAlarmFiredView(notification: NSNotification) {
    alarmFiredViewController = AlarmFiredPresenter.prepare(self)
    presentViewController(
      alarmFiredViewController!,
      animated: true,
      completion: nil
    )
  }

  // The user has dismissed the alarm. Kill the alarmFired view
  func dismissAlarmFiredView() {
    // dismiss and kill the alarmFiredViewController
    alarmFiredViewController?.dismissViewControllerAnimated(true, completion: nil)
    alarmFiredViewController = nil
  }

  // TODO: kill me
  @IBAction func testAlarm(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(
      Notifications.AlarmFired,
      object: nil
    )
  }

  /* Private */

  // Update the displayed time
  private func updateDisplay() {
    // Update the display labels
    primaryTimeLabel.text = currentTime.primaryStringForTwoPartDisplay()
    secondaryTimeLabel.text = currentTime.secondaryStringForTwoPartDisplay()
    // Unhide the overriden label if this alarm is an override
    overrideLabel.hidden = !AlarmManager.isOverridden()
    // Update the background image
    setBackgroundImage()
  }

  // Create and size our floating settings modal
  private func addSettingsModal() {
    if settingsModal == nil {
      let modalWidthRatio = CGFloat(0.92)
      let modalHeightRatio = CGFloat(0.8)
      settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
      self.addChildViewController(settingsModal)
      settingsModal.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      settingsModal.openPosition = self.view.center.y
      settingsModal.view.frame = CGRectMake(
        (self.view.frame.size.width - (self.view.frame.size.width * modalWidthRatio)) / 2.0,
        self.view.frame.size.height - settingsModal.scheduleView.frame.minY,
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
  }
  
  private func applyPlainShadow(view: UIView) {
    var layer = view.layer
    
    layer.shadowPath = UIBezierPath(rect: CGRectMake(0, 0, settingsModal.view.frame.width, settingsModal.view.frame.height)).CGPath
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSize(width: 0, height: 10)
    layer.shadowOpacity = 0.4
    layer.shadowRadius = 5
  }
  
  private func setBackgroundImage() {
    backgroundImagePresenter.alarmTime = currentTime.calculatedTime()
    backgroundImagePresenter.updateBackground(transition: true)
  }
}
