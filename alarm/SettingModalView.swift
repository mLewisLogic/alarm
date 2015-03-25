//
//  SettingModalView.swift
//  alarm
//
//  Created by Kevin Farst on 3/24/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class SettingsModalView {
  
  private var settingsModal: SettingsModalViewController!
  private var parentController: UIViewController!
  private var widthRatio = CGFloat(0.92)
  private var heightRatio = CGFloat(0.8)
  private var cornerRadius = CGFloat(12.0)
  
  required init(parentVC: UIViewController) {
      parentController = parentVC
    
      settingsModal = SettingsModalViewController(nibName: "SettingsModalViewController", bundle: nil)
      self.parentController.addChildViewController(settingsModal)
      settingsModal.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      settingsModal.openPosition = parentController.view.center.y
    
      setEdgeDimensionsAndStyling()
    
      settingsModal.closedPosition = settingsModal.view.center.y
      
      applyPlainShadow(settingsModal.view)

      parentController.view.addSubview(settingsModal.view)
      settingsModal.didMoveToParentViewController(parentController)
  }
  
  private func applyPlainShadow(view: UIView) {
    let layer = view.layer
    
    layer.shadowPath = UIBezierPath(rect: CGRectMake(0, 0, settingsModal.view.frame.width, settingsModal.view.frame.height)).CGPath
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOffset = CGSize(width: 0, height: 10)
    layer.shadowOpacity = 0.4
    layer.shadowRadius = 5
  }
  
  private func setEdgeDimensionsAndStyling() {
    settingsModal.view.frame = CGRectMake(
      (parentController.view.frame.size.width - (parentController.view.frame.size.width * widthRatio)) / 2.0,
      parentController.view.frame.size.height - settingsModal.topBorder.frame.minY,
      parentController.view.frame.size.width * widthRatio,
      parentController.view.frame.size.height * heightRatio
    )
    settingsModal.view.layer.cornerRadius = cornerRadius
    settingsModal.view.layer.masksToBounds = true
    settingsModal.view.clipsToBounds = true
  }
}