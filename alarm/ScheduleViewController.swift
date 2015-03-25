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

  // If the time picker is up, we're modifying a cell
  var cellBeingChanged: ScheduleTableViewCell?

  // The home view controls display of the time picker
  var timePickerManagerDelegate: TimePickerManagerDelegate!
  
  var containerView: UIView!

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
    
    scheduleTableView.delegate = self
    scheduleTableView.dataSource = self

    // Load in the alarms for presentation
    alarmEntityArray = AlarmManager.loadAlarmsOrdered()

    scheduleTableView.alwaysBounceVertical = false
    scheduleTableView.separatorColor = UIColor.clearColor()
    self.view.backgroundColor = UIColor.whiteColor()
    scheduleTableView.backgroundColor = UIColor.whiteColor()

    scheduleTableView.reloadData()
  }

  override func viewWillAppear(animated: Bool) {
    scheduleTableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let cell = scheduleTableView.dequeueReusableCellWithIdentifier("ScheduleTableViewCell") as ScheduleTableViewCell
    let containerHeight = cell.frame.height * 7
    containerView.backgroundColor = UIColor.grayColor()
    containerView.frame.size = CGSizeMake(containerView.frame.width, containerHeight)
    parentViewController?.viewDidLayoutSubviews()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /* Table functions */

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
    cell.contentView.autoresizingMask = .FlexibleHeight
    cell.delegate = self
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    NSLog("\(indexPath.row)")
  }


  /* Alarm cell time updating */

  // Delegate of DayOfWeekAlarmDelegate
  func updateTimeSelected(cell: ScheduleTableViewCell) {
    // Stash the cell under change
    cellBeingChanged = cell
    // Get the cell's underlying alarm and trigger a picker for it
    if let indexPath = scheduleTableView.indexPathForCell(cell) {
      let alarmEntity = alarmEntityArray[indexPath.row]
      timePickerManagerDelegate.showTimePicker(
        self,
        time: TimePresenter(alarmEntity: alarmEntity)
      )
    }
  }

  // Delegate callback from the time picker
  func timeSelected(time: TimePresenter) {
    updateCellBeingChanged(time)
    timePickerManagerDelegate.dismissTimePicker()
  }


  /* Private */
  
  // Update the displayed time
  private func updateCellBeingChanged(time: TimePresenter) {
    if let cell = cellBeingChanged {
      AlarmManager.updateAlarmEntity(cell.alarmEntity, timePresenter: time)
      // Update the display for the cell
      cell.updateDisplay()
      // Clear out our stashed cell reference
      cellBeingChanged = nil
    }
  }

}
