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
  }

  func wheelDisplayStr() -> String {
    // Special formatting for special times
    if hour == 0 && minute == 0 {
      return "midnight"
    } else if hour == 12 && minute == 0 {
      return "noon"
    } else {
      return String(format: "%02d : %02d", self.hour, self.minute)
    }
  }

  func tableDisplayStr() -> String {
    // Special formatting for special times
    if hour == 0 && minute == 0 {
      return "midnight"
    } else if hour == 12 && minute == 0 {
      return "noon"
    } else {
      return String(format: "%02d:%02d %@", self.hour, self.minute, self.amOrPm)
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
