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

class HomeViewController: UIViewController, TimePickerDelegate, TimePickerManagerDelegate, AlarmFiredViewDelegate, UIGestureRecognizerDelegate {

  @IBOutlet weak var wakeUpLabel: UILabel!
  @IBOutlet weak var primaryTimeLabel: UILabel!
  @IBOutlet weak var secondaryTimeLabel: UILabel!
  
  let widthRatio = CGFloat(0.92)
  let heightRatio = CGFloat(0.8)
  let cornerRadius = CGFloat(12.0)
  let activationButtonWidth = CGFloat(160)
  
  var currentTime: TimePresenter!
  var blurViewPresenter: BlurViewPresenter!
  var timePickerViewController: UIViewController?
  var activationButtonCircleView: ButtonCircleView!
  var settingsModal: SettingsModalViewController!
  var backgroundImagePresenter: BackgroundImagePresenter!
  var backgroundImageView = UIImageView()
  var alarmFiredViewController: AlarmFiredViewController?
  var alarmTimeBackdropView = UIView()
  var changeTimeTapRecognizer: UITapGestureRecognizer!
  var tapView = UIView()
  
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
    addActivationButton()
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

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "updateActivationButton",
      name: Notifications.AlarmActivated,
      object: nil
    )

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "updateActivationButton",
      name: Notifications.AlarmDeactivated,
      object: nil
    )
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "toggleTimePickerButton",
      name: Notifications.AlarmActivated,
      object: nil
    )

    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "toggleTimePickerButton",
      name: Notifications.AlarmDeactivated,
      object: nil
    )
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    addAlarmTimeBackdropView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

  // The "activate" button was triggered
  func activateTriggered() {
    if AlarmHelper.isActivated() {
      AlarmHelper.deactivateAlarm()
    } else {
      AlarmHelper.activateAlarm()
    }
  }


  // Update the activation button to reflect current state
  func updateActivationButton() {
    if AlarmHelper.isActivated() {
      activationButtonCircleView.labelText = "DEACTIVATE"
    } else {
      activationButtonCircleView.labelText = "ACTIVATE"
    }
  }

  // Enable or disable the time picker tap gesture recognizer
  func toggleTimePickerButton() {
    if AlarmHelper.isActivated() {
      tapView.userInteractionEnabled = false
    } else {
      tapView.userInteractionEnabled = true
    }
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
  
  func timeChangeSelected(sender: UITapGestureRecognizer) {
    showTimePicker(self, time: currentTime)
  }

  // TODO: kill me
  @IBAction func testAlarm(sender: UIButton) {
    NSNotificationCenter.defaultCenter().postNotificationName(
      Notifications.AlarmFired,
      object: nil
    )
    AlarmHelper.deactivateAlarm()
  }

  /* Private */

  // Update the displayed time
  private func updateDisplay() {
    // Update the display labels
    primaryTimeLabel.text = currentTime.primaryStringForTwoPartDisplay()
    secondaryTimeLabel.text = currentTime.secondaryStringForTwoPartDisplay()
    // Update the background image
    setBackgroundImage()
  }

  // Add our activation button
  private func addActivationButton() {
    //activationButtonCircleView
    // 107 277
    // 100 100
    if activationButtonCircleView == nil {
      activationButtonCircleView = ButtonCircleView(
        frame: CGRectMake(
          view.center.x - activationButtonWidth / 2,
          view.frame.height * 0.65 - activationButtonWidth / 2,
          activationButtonWidth,
          activationButtonWidth
        )
      )
      activationButtonCircleView.labelText = "ACTIVATE"
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "activateTriggered")
      activationButtonCircleView.addGestureRecognizer(tapRecognizer)
      view.addSubview(activationButtonCircleView)
    }
  }

  // Create and size our floating settings modal
  private func addSettingsModal() {
    if settingsModal == nil {
      settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
      self.addChildViewController(settingsModal)
      settingsModal.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      settingsModal.openPosition = self.view.center.y
      settingsModal.view.frame = CGRectMake(
        (self.view.frame.size.width - (self.view.frame.size.width * widthRatio)) / 2.0,
        self.view.frame.size.height - settingsModal.scheduleView.frame.minY,
        self.view.frame.size.width * widthRatio,
        self.view.frame.size.height * heightRatio
      )
      settingsModal.view.layer.cornerRadius = cornerRadius
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
  
  private func addAlarmTimeBackdropView() {
    alarmTimeBackdropView.frame = CGRectMake((self.view.frame.width - (self.view.frame.width * widthRatio)) / 2, wakeUpLabel.frame.minY - 20, self.view.frame.width * widthRatio, secondaryTimeLabel.frame.maxY - wakeUpLabel.frame.minY + 20)
    alarmTimeBackdropView.backgroundColor = UIColor.blackColor()
    alarmTimeBackdropView.alpha = 0.3
    
    tapView.frame = alarmTimeBackdropView.frame
    changeTimeTapRecognizer = UITapGestureRecognizer(target: self, action: "timeChangeSelected:")
    changeTimeTapRecognizer.delegate = self
    tapView.addGestureRecognizer(changeTimeTapRecognizer)
    
    self.view.insertSubview(alarmTimeBackdropView, aboveSubview: backgroundImageView)
    self.view.insertSubview(tapView, aboveSubview: primaryTimeLabel)
  }
  
}
