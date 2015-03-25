//
//  SettingsModalViewController.swift
//  alarm
//
//  Created by Kevin Farst on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class SettingsModalViewController: UIViewController {

  @IBOutlet weak var alarmLabel: UILabel!
  @IBOutlet weak var scheduleView: UIView!
  
  var openPosition: CGFloat!
  var closedPosition: CGFloat!
  var scheduleVC: ScheduleViewController!
  
  private var open = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
    self.alarmLabel.textColor = UIColor.lightGrayColor()
    
    scheduleVC = ScheduleViewController(nibName: "ScheduleViewController", bundle: nil)
    scheduleVC.containerView = scheduleView
    self.addChildViewController(scheduleVC)
    scheduleView.addSubview(scheduleVC.view)
    scheduleVC.didMoveToParentViewController(self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    addScheduleView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func addScheduleView() {
    scheduleVC.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
    scheduleView.backgroundColor = UIColor.whiteColor()
    scheduleView.layer.masksToBounds = true
    scheduleView.clipsToBounds = true
    scheduleView.center = self.view.center
    
    scheduleVC.view.layer.masksToBounds = true
    scheduleVC.view.clipsToBounds = true

    // Let the settings modal know who controls the time picker
    scheduleVC.timePickerManagerDelegate = self.parentViewController! as HomeViewController
  }
  

  @IBAction func moveModal(sender: UIPanGestureRecognizer) {
    let velocity = sender.velocityInView(self.view)

    switch sender.state {
    case .Changed:
      let translation = sender.translationInView(self.view)
      let newPosition = CGFloat(sender.view!.center.y + translation.y)

      if newPosition > openPosition && newPosition < closedPosition {
        sender.view!.center.y = newPosition
        sender.setTranslation(CGPointZero, inView: self.view)
      }
    case .Ended:
      let damping: CGFloat! = 0.8
      let initVelocity: CGFloat! = 1.6

      if velocity.y < 0 {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initVelocity, options: .CurveEaseInOut, animations: { () -> Void in
          self.view.center.y = self.openPosition
          }, completion: { finished in
            if finished {
              self.open = true
            }
        })
      } else if velocity.y > 0 {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: initVelocity, options: .CurveEaseInOut, animations: { () -> Void in
          self.view.center.y = self.closedPosition
          }, completion: { finished in
            if finished {
              self.open = false
            }
        })
      }
      break
    default:
      break
    }
  }
  
}
