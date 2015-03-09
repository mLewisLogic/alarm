//
//  TimeElement.swift
//  alarm
//
//  Created by Michael Lewis on 3/8/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class TimeElement {
  var hour: Int
  var minute: Int
  var displayStr: String
  var amOrPm: String // either "am" or "pm"


  init(hour: Int, minute: Int) {
    // Determine AM vs PM and adjust the hour to a 12 hour clock
    if hour < 12 {
      self.hour = hour
      self.amOrPm = "am"
    } else {
      self.hour = hour - 12
      self.amOrPm = "pm"
    }

    if self.hour == 0 {
      self.hour = 12
    }

    self.minute = minute

    // Special formatting for special times
    if hour == 0 && minute == 0 {
      self.displayStr = "midnight"
    } else if hour == 12 && minute == 0 {
      self.displayStr = "noon"
    } else {
      self.displayStr = String(format: "%02d : %02d", self.hour, self.minute)
    }

  }

  // Generate all of the time elements that we will allow
  class func generateAllElements() -> Array<TimeElement> {
    return (0...23).map {
      hour in
      [0, 15, 30, 45].map {
        minute in
        TimeElement(hour: hour, minute: minute)
      }
    }.reduce([], +)
  }
}
