//
//  TimePickerPresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class TimePickerPresenter {

  // Present the alarm picker over a given view
  class func preparePicker(_ delegate: TimePickerDelegate, time: TimePresenter) -> TimePickerViewController {
    // Create a new AlarmView overlaying
    let timePickerViewController = TimePickerViewController(
      nibName: "TimePickerViewController",
      bundle: nil
    )
    // Assign it's delegate as this view
    timePickerViewController.delegate = delegate
    timePickerViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    timePickerViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

    // Let the picker know what it should have selected
    timePickerViewController.startingTimePresenter = time

    return timePickerViewController
  }
}
