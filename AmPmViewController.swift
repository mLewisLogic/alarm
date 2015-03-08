//
//  AmPmViewController.swift
//  alarm
//
//  Created by Kevin Farst on 3/7/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class AmPmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var amPmView: UITableView!
    
    var amPm = ["AM", "PM"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        amPmView.delegate = self
        amPmView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amPm.count
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
