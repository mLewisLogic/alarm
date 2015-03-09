//
//  TodayViewController.swift
//  alarm
//
//  Created by Kevin Farst on 3/5/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet weak var hourView: UIView!
    @IBOutlet weak var minuteView: UIView!
    @IBOutlet weak var amPmView: UIView!
    
    var timePicker = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timePicker = [[self.hourView as UIView, HourViewController(nibName: "HourView", bundle: nil)],
            [self.minuteView, MinuteViewController(nibName: "MinuteView", bundle: nil)],
            [self.amPmView, AmPmViewController(nibName: "AmPmView", bundle: nil)]]
        
        for time in timePicker {
           addViewController(time[0] as UIView, vc: time[1] as UIViewController)
        }
        
        hourView.frame = CGRectMake(0, 0, self.view.frame.width / 3, self.view.frame.height)
        minuteView.frame = CGRectMake(self.view.frame.width / 3, 0, self.view.frame.width / 3, self.view.frame.height)
        amPmView.frame = CGRectMake((self.view.frame.width / 3) * 2, 0, self.view.frame.width / 3, self.view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addViewController (subView: UIView!, vc: UIViewController!) {
        self.addChildViewController(vc)
        vc.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        vc.view.frame = subView.bounds
        subView.addSubview(vc.view)
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
