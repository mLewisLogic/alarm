//
//  AlarmFiredPresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/21/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class AlarmFiredPresenter {

  // Present the alarm picker over a given view
  class func prepare(delegate: AlarmFiredViewDelegate) -> AlarmFiredViewController {
    // Create a new AlarmView overlaying
    var viewController = AlarmFiredViewController(
      nibName: "AlarmFiredViewController",
      bundle: nil
    )
    // Assign it's delegate as this view
    viewController.delegate = delegate
    viewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

    return viewController
  }

}