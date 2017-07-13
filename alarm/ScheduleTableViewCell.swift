//
//  ScheduleTableViewCell.swift
//  alarm
//
//  Created by Michael Lewis on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

protocol DayOfWeekAlarmDelegate {
  func updateTimeSelected(_ cell: ScheduleTableViewCell)
}

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var timeButton: UIButton!

  var alarmEntity: AlarmEntity! {
    didSet {
      updateDisplay()
    }
  }
  
  var delegate: DayOfWeekAlarmDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.backgroundColor = UIColor.white
    self.dayLabel.textColor = UIColor.black
    self.timeButton.setTitleColor(UIColor.black, for: UIControlState.normal)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }

  // Triggered when the user taps the time
  @IBAction func timeChangeSelected(_ sender: UIButton) {
    delegate.updateTimeSelected(self)
  }

  // Given details of our alarm entity, update the display
  func updateDisplay() {
    dayLabel.text = alarmEntity.dayOfWeekForDisplay()
    timeButton.setTitle(alarmEntity.stringForTableDisplay(), for: UIControlState.normal)
  }
}
