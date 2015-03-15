//
//  RawTime.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

// RawTime is a helper class that contains an hour/minute pair
// It provides some _very_ basic logic for converting between
// 24-hour and 12-hour time. It stores in 24-hour time.
struct RawTime: Comparable, Hashable {
  enum AmPm {
    case AM
    case PM
  }

  // Only `hour24` and `minute` are required
  var hour24: Int
  var minute: Int

  // All other variables are derived
  // `hour12` is the hours, as it would be displayed on a 12-hour
  // clock.
  var hour12: Int {
    get {
      if hour24 == 0 {
        return 12
      } else if hour24 < 13 {
        return hour24
      } else {
        return hour24 - 12
      }
    }
  }

  var amOrPm: AmPm {
    if hour24 < 12 {
      return .AM
    } else {
      return .PM
    }
  }

  var hashValue: Int {
    get {
      return hour24.hashValue ^ minute.hashValue
    }
  }
}

// Comparison operators for RawTime
func <(left: RawTime, right: RawTime) -> Bool {
  return (
    left.hour24 < right.hour24 ||
    (left.hour24 == right.hour24 && left.minute < right.minute)
  )
}

func ==(left: RawTime, right: RawTime) -> Bool {
  return left.hour24 == right.hour24 && left.minute == right.minute
}
