//
//  AlarmPickerPresenter.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class AlarmPickerPresenter {

  let delegate: TimePickerDelegate

  init(delegate: TimePickerDelegate) {
    self.delegate = delegate
  }

  // Present the alarm picker over a given view
  func prepareAlarmPicker(time: TimePresenter) -> TimePickerViewController {
    // Create a new AlarmView overlaying
    var timePickerViewController = TimePickerViewController(
      nibName: "TimePickerViewController",
      bundle: nil
    )
    // Assign it's delegate as this view
    timePickerViewController.delegate = self.delegate
    timePickerViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    timePickerViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

    // Let the picker know what it should have selected
    timePickerViewController.startingTimePresenter = time

    return timePickerViewController
  }
}
