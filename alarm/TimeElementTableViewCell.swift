//
//  TimeElementTableViewCell.swift
//  alarm
//
//  Created by Kevin Farst on 3/7/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import UIKit

class TimeElementTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeElement: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
