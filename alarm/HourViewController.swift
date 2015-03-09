//
//  HourViewController.swift
//  alarm
//
//  Created by Kevin Farst on 3/7/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class HourViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hourView: UITableView!
    
    var hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        hourView.registerNib(UINib(nibName: "TimeElementTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeElementTableViewCell")
        hourView.delegate = self
        hourView.dataSource = self
        hourView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = hourView.dequeueReusableCellWithIdentifier("TimeElementTableViewCell") as TimeElementTableViewCell
        cell.timeElement.text = String(hours[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hours.count
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
