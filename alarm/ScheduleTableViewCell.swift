//
//  ScheduleTableViewCell.swift
//  alarm
//
//  Created by Michael Lewis on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

protocol DayOfWeekAlarmDelegate {
  func updateTimeSelected(cell: ScheduleTableViewCell)
}

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var timeButton: UIButton!
  @IBOutlet weak var activeSwitch: UISwitch!

  var alarmEntity: AlarmEntity! {
    didSet {
      updateDisplay()
    }
  }
  
  var delegate: DayOfWeekAlarmDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

  @IBAction func switchChanged(sender: UISwitch) {
    //NSLog("Switch toggled: \(sender.on)")
  }
  
  @IBAction func timeChangeSelected(sender: UIButton) {
    delegate.updateTimeSelected(self)
  }

  // Given details of our alarm entity, update the display
  func updateDisplay() {
    dayLabel.text = alarmEntity.dayOfWeekForDisplay()
    timeButton.setTitle(alarmEntity.stringForTableDisplay(), forState: UIControlState.Normal)
    //activeSwitch.on = alarmEntity.enabled
  }
}
