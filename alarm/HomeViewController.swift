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
  @IBOutlet weak var doNotCloseLabel: UILabel!
  
  let widthRatio = CGFloat(0.92)
  let heightRatio = CGFloat(0.8)
  let cornerRadius = CGFloat(12.0)
  let activationButtonWidth = CGFloat(160)
  
  var currentTime: TimePresenter!
  var blurViewPresenter: BlurViewPresenter!
  var timePickerViewController: UIViewController?
  var activationButtonCircleView: ButtonCircleView!
  var settingsModal: SettingsModalView!
  var backgroundImagePresenter: BackgroundImagePresenter!
  var backgroundImageView = UIImageView()
  var alarmFiredViewController: AlarmFiredViewController?
  var alarmTimeBackdropView = VerticalGradientView()
  var changeTimeTapRecognizer: UITapGestureRecognizer!
  var tapView = UIView()
  var wakeUpLabelOriginalY: CGFloat!
  var primaryTimeLabelOriginalY: CGFloat!
  var secondaryTimeLabelOriginalY: CGFloat!
  var separatorView = UIView()
  var cancelAlarmButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Insert the background image in our view structure
    self.view.insertSubview(backgroundImageView, atIndex: 0)

    // Set up a default TimePresenter
    currentTime = TimePresenter(alarmEntity: AlarmManager.nextAlarm())
    // Set up our presenters for later use
    blurViewPresenter = BlurViewPresenter(parent: self.view)
    
    self.view.addSubview(separatorView)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)

    // Set the sizing for the background view
    backgroundImageView.frame = self.view.frame
    backgroundImagePresenter = BackgroundImagePresenter(alarmTime: currentTime.calculatedTime()!,
      imageView: backgroundImageView)
    
    wakeUpLabelOriginalY = wakeUpLabel.center.y
    primaryTimeLabelOriginalY = primaryTimeLabel.center.y
    secondaryTimeLabelOriginalY = secondaryTimeLabel.center.y
    
    updateDisplay()
    addActivationButton()
    addSettingsModal()
    addAlarmTimeBackdropView()
    addCancelButton()

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
      transitionToAlarmActivatedView()
    } else {
      transitionToAlarmDeactivatedView()
    }
  }

  // Enable or disable the time picker tap gesture recognizer
  func toggleTimePickerButton() {
    if AlarmHelper.isActivated() {
      tapView.userInteractionEnabled = false
      cancelAlarmButton.userInteractionEnabled = true
    } else {
      tapView.userInteractionEnabled = true
      cancelAlarmButton.userInteractionEnabled = false
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
  
  private func transitionToAlarmActivatedView() {
    let centerPoint = self.view.frame.height / 3
    let wakeUpLabelDistance = self.primaryTimeLabel.center.y - self.wakeUpLabel.center.y
    let secondaryTimeLabelDistance = self.secondaryTimeLabel.center.y - self.primaryTimeLabel.center.y
    
    UIView.animateWithDuration(0.5,
      delay: 0.0,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.activationButtonCircleView.alpha = 0.0
        return
      }, completion: { finished in
        if finished {
          UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
              self.wakeUpLabel.center = CGPoint(x: self.wakeUpLabel.center.x, y: centerPoint -  wakeUpLabelDistance)
              self.primaryTimeLabel.center = CGPoint(x: self.primaryTimeLabel.center.x, y: centerPoint)
              self.secondaryTimeLabel.center = CGPoint(x: self.secondaryTimeLabel.center.x, y: centerPoint + secondaryTimeLabelDistance)
              
              return
            },
            completion: { finished in
              if finished {
                let distanceY = self.secondaryTimeLabel.hidden ? centerPoint : secondaryTimeLabelDistance + centerPoint
                
                self.separatorView.alpha = 0.0
                self.separatorView.backgroundColor = UIColor.whiteColor()
                self.separatorView.frame = CGRectMake(self.primaryTimeLabel.frame.minX,
                  distanceY + 40,
                  self.primaryTimeLabel.frame.width,
                  1
                )
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                  self.separatorView.alpha = 1.0
                  
                  self.settingsModal.toggleInView(hide: true)
                  
                  self.doNotCloseLabel.sizeToFit()
                  self.doNotCloseLabel.center = CGPoint(x: self.view.center.x, y: self.view.frame.height * 0.75)
                  self.doNotCloseLabel.alpha = 1.0
                  
                  self.cancelAlarmButton.center = CGPoint(x: self.view.frame.width / 2 , y: self.separatorView.frame.maxY + self.cancelAlarmButton.frame.height + 10)
                  self.cancelAlarmButton.alpha = 1.0
                })
              }
            }
          )
        }
    })
  }
  
  private func transitionToAlarmDeactivatedView() {
    UIView.animateWithDuration(0.5,
      delay: 0.0,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.settingsModal.toggleInView(hide: false)
        self.separatorView.alpha = 0.0
        self.cancelAlarmButton.alpha = 0.0
        self.doNotCloseLabel.alpha = 0.0
        
        self.wakeUpLabel.center = CGPoint(x: self.wakeUpLabel.center.x, y: self.wakeUpLabelOriginalY)
        self.primaryTimeLabel.center = CGPoint(x: self.primaryTimeLabel.center.x, y: self.primaryTimeLabelOriginalY)
        self.secondaryTimeLabel.center = CGPoint(x: self.secondaryTimeLabel.center.x, y: self.secondaryTimeLabelOriginalY)
        
        self.activationButtonCircleView.alpha = 1.0
        return
      }, completion: { finished in
    })
  }
  
  private func addCancelButton() {
    cancelAlarmButton.setTitle("Cancel Alarm", forState: UIControlState.Normal)
    cancelAlarmButton.titleLabel?.font = UIFont(name: "Avenir Medium", size: 32.0)
    cancelAlarmButton.sizeToFit()
    cancelAlarmButton.alpha = 0.0
    cancelAlarmButton.addTarget(self, action: "activateTriggered", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(cancelAlarmButton)
  }

  // Update the displayed time
  private func updateDisplay() {
    // Update the display labels
    primaryTimeLabel.text = currentTime.primaryStringForTwoPartDisplay()
    
    if currentTime.secondaryStringForTwoPartDisplay().isEmpty {
      secondaryTimeLabel.hidden = true
    } else {
      secondaryTimeLabel.hidden = false
      secondaryTimeLabel.text = currentTime.secondaryStringForTwoPartDisplay()
    }
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
          view.frame.height * 0.5 - activationButtonWidth / 2,
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
      settingsModal = SettingsModalView(parentVC: self)
    }
  }
  
  private func setBackgroundImage() {
    backgroundImagePresenter.alarmTime = currentTime.calculatedTime()
    backgroundImagePresenter.updateBackground(transition: true)
  }
  
  private func addAlarmTimeBackdropView() {
    alarmTimeBackdropView.frame = CGRectMake(
      0,
      0,
      self.view.frame.width,
      self.view.frame.height * 0.67 - wakeUpLabel.frame.minY + 60
    )
    alarmTimeBackdropView.backgroundColor = UIColor.clearColor()
    self.view.insertSubview(
      alarmTimeBackdropView,
      aboveSubview: backgroundImageView
    )

    tapView.frame = alarmTimeBackdropView.frame
    changeTimeTapRecognizer = UITapGestureRecognizer(target: self, action: "timeChangeSelected:")
    changeTimeTapRecognizer.delegate = self
    tapView.addGestureRecognizer(changeTimeTapRecognizer)

    self.view.insertSubview(tapView, aboveSubview: primaryTimeLabel)
  }
  
}
