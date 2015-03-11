//
//  AlarmTimeEntity.swift
//  alarm
//
//  Created by Kevin Farst on 3/10/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation
import CoreData

@objc(AlarmTimeEntity)
class AlarmTimeEntity: NSManagedObject {

    @NSManaged var dayOfWeek: String
    @NSManaged var time: NSDate

}
