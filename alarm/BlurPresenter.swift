//
//  BlurPresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/14/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

// This will create a blur layer on top of the parent view.

class BlurPresenter {

  let blurEffect: UIBlurEffect
  let vibrancyEffect: UIVibrancyEffect

  let blurEffectView: UIVisualEffectView
  let vibrancyEffectView: UIVisualEffectView

  let parentView: UIView

  init(parent: UIView) {
    // Stash the parent
    self.parentView = parent

    // Initialize the effects
    blurEffect = UIBlurEffect(style: .Dark)
    vibrancyEffect = UIVibrancyEffect(forBlurEffect: self.blurEffect)

    // Create views on top of this controller's view
    blurEffectView = UIVisualEffectView(effect: blurEffect) as UIVisualEffectView
    vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

    // Set up the dimensions
    resetBounds()

    // Set up the view relationships
    blurEffectView.addSubview(vibrancyEffectView)
    parent.addSubview(blurEffectView)

    // Make sure the blur starts out hidden
    hideBlur()
  }

  func showBlur() {
    NSLog("Showing blur")
    resetBounds()
    blurEffectView.hidden = false
  }

  func hideBlur() {
    blurEffectView.hidden = true
  }

  private func resetBounds() {
    blurEffectView.frame = self.parentView.bounds
    vibrancyEffectView.frame = self.parentView.bounds
  }
}
