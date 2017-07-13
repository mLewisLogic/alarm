//
//  SettingModalView.swift
//  alarm
//
//  Created by Kevin Farst on 3/24/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class SettingsModalView {
  
  fileprivate var settingsModal: SettingsModalViewController!
  fileprivate var parentController: UIViewController!
  fileprivate var widthRatio = CFloat(0.92)
  fileprivate var heightRatio = CFloat(0.8)
  fileprivate var cornerRadius = CFloat(6.0)
  
  required init(parentVC: UIViewController) {
      parentController = parentVC
    
      settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
      self.parentController.addChildViewController(settingsModal)
      settingsModal.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      settingsModal.openPosition = parentController.view.center.y
    
      setEdgeDimensionsAndStyling()
    
      settingsModal.closedPosition = settingsModal.view.center.y
      
      applyPlainShadow(settingsModal.view)

      parentController.view.addSubview(settingsModal.view)
      settingsModal.didMove(toParentViewController: parentController)
  }
  
  func toggleInView(hide hidden: Bool) {
    if hidden {
      settingsModal.view.center.y = settingsModal.view.center.y + settingsModal.closedPosition
    } else {
      settingsModal.view.center.y = settingsModal.closedPosition
    }
  }
  
  fileprivate func applyPlainShadow(_ view: UIView) {
    let layer = view.layer
    
    layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: settingsModal.view.frame.width, height: settingsModal.view.frame.height)).cgPath
    layer.shadowColor = SWColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 10)
    layer.shadowOpacity = 0.4
    layer.shadowRadius = 5
  }
  
  fileprivate func setEdgeDimensionsAndStyling() {
    settingsModal.view.frame = CGRect(
        x: (parentController.view.frame.size.width - parentController.view.frame.size.width.multiplied(by: CGFloat(widthRatio))) / 2.0,
        y: parentController.view.frame.size.height - settingsModal.topBorder.frame.minY,
        width: parentController.view.frame.size.width.multiplied(by: CGFloat(widthRatio)),
        height: parentController.view.frame.size.height.multiplied(by: CGFloat(heightRatio))
    )
    settingsModal.view.layer.cornerRadius = CGFloat(cornerRadius)
    settingsModal.view.layer.masksToBounds = true
    settingsModal.view.clipsToBounds = true
  }
}
