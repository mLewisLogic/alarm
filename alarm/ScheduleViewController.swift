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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    scheduleTableView.register(
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
    scheduleTableView.separatorColor = UIColor.clear
    self.view.backgroundColor = UIColor.white
    scheduleTableView.backgroundColor = UIColor.white

    scheduleTableView.reloadData()
  }

  override func viewWillAppear(_ animated: Bool) {
    scheduleTableView.reloadData()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let cell = scheduleTableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell") as! ScheduleTableViewCell
    _ = cell.frame.height * 7
    parent?.viewDidLayoutSubviews()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /* Table functions */

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return alarmEntityArray.count
  }

  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: "ScheduleTableViewCell",
        for: indexPath as IndexPath
      ) as! ScheduleTableViewCell
    cell.alarmEntity = alarmEntityArray[indexPath.row]
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    cell.contentView.autoresizingMask = .flexibleHeight
    cell.delegate = self
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    NSLog("\(indexPath.row)")
  }


  /* Alarm cell time updating */

  // Delegate of DayOfWeekAlarmDelegate
  func updateTimeSelected(_ cell: ScheduleTableViewCell) {
    // Stash the cell under change
    cellBeingChanged = cell
    // Get the cell's underlying alarm and trigger a picker for it
    if let indexPath = scheduleTableView.indexPath(for: cell) {
      let alarmEntity = alarmEntityArray[indexPath.row]
      timePickerManagerDelegate.showTimePicker(
        self,
        time: TimePresenter(alarmEntity: alarmEntity)
      )
    }
  }

  // Delegate callback from the time picker
  func timeSelected(_ time: TimePresenter) {
    updateCellBeingChanged(time)
    timePickerManagerDelegate.dismissTimePicker()
  }


  /* Private */
  
  // Update the displayed time
  fileprivate func updateCellBeingChanged(_ time: TimePresenter) {
    if let cell = cellBeingChanged {
      AlarmManager.updateAlarmEntity(cell.alarmEntity, timePresenter: time)
      // Update the display for the cell
      cell.updateDisplay()
      // Clear out our stashed cell reference
      cellBeingChanged = nil
    }
  }

}
