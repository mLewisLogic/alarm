//
//  ScheduleTableViewCell.swift
//  alarm
//
//  Created by Michael Lewis on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var activeSwitch: UISwitch!

  var alarmEntity: AlarmEntity! {
    didSet {
      dayLabel.text = alarmEntity.dayOfWeekForDisplay()
      timeLabel.text = alarmEntity.timeForTableDisplay()
      //activeSwitch.on = alarmEntity.enabled
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    self.contentView.userInteractionEnabled = false
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  @IBAction func switchChanged(sender: UISwitch) {
    NSLog("Switch toggled: \(sender.on)")
  }
}
