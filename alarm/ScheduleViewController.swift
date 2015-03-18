//
//  ScheduleViewController.swift
//  alarm
//
//  Created by Michael Lewis on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimePickerDelegate, DayOfWeekAlarmDelegate {
  @IBOutlet weak var scheduleTableView: UITableView!

  // An array of 7 TimeEntities
  // One for each day of the week (Sun-Sat)
  var alarmEntityArray: Array<AlarmEntity>!

  var blurViewPresenter: BlurViewPresenter!
  var alarmPickerPresenter: AlarmPickerPresenter!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    scheduleTableView.registerNib(
      UINib(
        nibName: "ScheduleTableViewCell",
        bundle: nil
      ),
      forCellReuseIdentifier: "ScheduleTableViewCell"
    )

    // Set up our dummy data
    createDummyAlarms()

    // Set up our presenters for later use
    blurViewPresenter = BlurViewPresenter(parent: self.view)
    alarmPickerPresenter = AlarmPickerPresenter(delegate: self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alarmEntityArray.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "ScheduleTableViewCell",
      forIndexPath: indexPath
      ) as ScheduleTableViewCell
    cell.alarmEntity = alarmEntityArray[indexPath.row]
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    cell.delegate = self
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    NSLog("\(indexPath.row)")
  }
  
  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    updateDisplayTime()
  }
  
  func updateTimeSelected(cell: ScheduleTableViewCell) {
    if let indexPath = scheduleTableView.indexPathForCell(cell) {
      let alarmEntity = alarmEntityArray[indexPath.row]
      
      blurViewPresenter.showBlur()

      // Prepare and present the alarm picker controller
      let timePickerViewController = alarmPickerPresenter.prepareAlarmPicker(TimePresenter(alarmEntity: alarmEntity))
      presentViewController(timePickerViewController, animated: true, completion: nil)
    }
  }


  /* Private */
  
  // Update the displayed time
  private func updateDisplayTime() {
    // TODO: Implement me
  }
  
  // TODO: We need to replace this with live Core Data entities from the database
  // This might be useful as a first-time user initialization routine.
  private func createDummyAlarms() {
    alarmEntityArray = AlarmEntity.DayOfWeek.allValues.map {
      (dayOfWeekEnum: AlarmEntity.DayOfWeek) -> AlarmEntity in
      var alarmEntity = AlarmEntity.MR_createEntity() as AlarmEntity
      alarmEntity.dayOfWeekEnum = dayOfWeekEnum
      alarmEntity.alarmTypeEnum = .Time
      alarmEntity.setValue(false, forKey: "enabled")
      alarmEntity.hour = 7
      alarmEntity.minute = 0
      return alarmEntity
    }
  }
}
