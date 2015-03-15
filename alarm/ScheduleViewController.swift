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
  var blurPresenter: BlurPresenter!

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
    blurPresenter = BlurPresenter(parent: self.view)
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
  func timeSelected(time: TimeElement) {
    updateDisplayTime()
  }
  
  func updateTimeSelected(cell: ScheduleTableViewCell) {
    if let indexPath = scheduleTableView.indexPathForCell(cell) {
      let alarmEntity = alarmEntityArray[indexPath.row]
      
      blurPresenter.showBlur()
      
      // Create a new AlarmView overlaying
      var alarmViewController = AlarmViewController(
        nibName: "AlarmViewController",
        bundle: nil
      )
      // Assign it's delegate as this view
      alarmViewController.delegate = self
      alarmViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
      alarmViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
      
      // Present the new controller
      presentViewController(alarmViewController, animated: true, completion: nil)
    }
  }
  
  // Update the displayed time
  private func updateDisplayTime() {
  }
  
  // TODO: We need to replace this with live Core Data entities from the database
  // This might be useful as a first-time user initialization routine.
  private func createDummyAlarms() {
    alarmEntityArray = AlarmEntity.DayOfWeek.allValues.map {
      (dayOfWeekEnum: AlarmEntity.DayOfWeek) -> AlarmEntity in
      var alarmEntity = AlarmEntity.MR_createEntity() as AlarmEntity
      //alarmEntity.setValue(dayOfWeekEnum, forKey: "dayOfWeekEnum")
      alarmEntity.dayOfWeekEnum = dayOfWeekEnum
      alarmEntity.alarmTypeEnum = .Time
      alarmEntity.setValue(false, forKey: "enabled")
      alarmEntity.hour = 7
      alarmEntity.minute = 0
      return alarmEntity
    }
  }
}
