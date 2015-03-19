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
  var timePickerViewController: UIViewController?
  // The home view controls display of the time picker
  var timePickerManagerDelegate: TimePickerManagerDelegate!

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

    // Load in the alarms for presentation
    alarmEntityArray = AlarmManager.loadAlarmsOrdered()

    // Set up our presenters for later use
    
    blurViewPresenter = BlurViewPresenter(parent: self.view)

    scheduleTableView.alwaysBounceVertical = false;
    scheduleTableView.separatorColor = UIColor.clearColor()
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
    timePickerManagerDelegate.dismissTimePicker()
  }
  
  func updateTimeSelected(cell: ScheduleTableViewCell) {
    if let indexPath = scheduleTableView.indexPathForCell(cell) {
      let alarmEntity = alarmEntityArray[indexPath.row]
      timePickerManagerDelegate.showTimePicker(
        self,
        time: TimePresenter(alarmEntity: alarmEntity)
      )
    }
  }


  /* Private */
  
  // Update the displayed time
  private func updateDisplayTime() {
    // TODO: Implement me
  }

}
