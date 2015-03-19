//
//  BackgroundImagePresenter.swift
//  alarm
//
//  Created by Kevin Farst on 3/18/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import Foundation

class BackgroundImagePresenter {
  var sunrise: RawTime!
  var sunset: RawTime!
  let alarmTime: RawTime!
  
  init(alarmTime: RawTime) {
    // Set calculated defaults
    self.sunrise = TimePresenter(type: AlarmEntity.AlarmType.Sunrise).calculatedTime()
    self.sunset = TimePresenter(type: AlarmEntity.AlarmType.Sunset).calculatedTime()
    self.alarmTime = alarmTime
    
    // Set hard defaults in case of calculation failures
    if sunrise == nil {
      sunrise = RawTime(hour24: 8, minute: 00)
    }
    
    if sunset == nil {
      sunset = RawTime(hour24: 20, minute: 00)
    }
  }
  
  func getImage() -> UIImageView! {
    // Create and return the background image view
    let imageName = self.getImageName()
    let image = UIImage(named: imageName)
    return UIImageView(image: image)
  }
  
  private func getImageName() -> String! {
    if alarmTime.hour24 >= sunrise.hour24 - 2 && alarmTime.hour24 <= sunrise.hour24 + 2 {
      // Sunrise
      return "sunrise.png"
    } else if alarmTime.hour24 >= sunset.hour24 - 2 && alarmTime.hour24 <= sunset.hour24 + 2 {
      // Sunset
      return "sunset.png"
    } else if alarmTime.hour24 > sunrise.hour24 + 2 && alarmTime.hour24 < sunset.hour24 - 2 {
      // Day
      return "day.jpg"
    } else {
      // Night
      return "night.jpg"
    }
  }
}