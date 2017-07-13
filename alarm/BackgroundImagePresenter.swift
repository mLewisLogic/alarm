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
  var alarmTime: RawTime!
  let imageView: UIImageView!
  
  init(alarmTime: RawTime, imageView: UIImageView) {
    // Set calculated defaults
    self.sunrise = TimePresenter(type: AlarmEntity.AlarmType.Sunrise).calculatedTime()
    self.sunset = TimePresenter(type: AlarmEntity.AlarmType.Sunset).calculatedTime()
    self.alarmTime = alarmTime
    self.imageView = imageView
    
    // Set hard defaults in case of calculation failures
    if sunrise == nil {
      sunrise = RawTime(hour24: 8, minute: 00)
    }
    
    if sunset == nil {
      sunset = RawTime(hour24: 20, minute: 00)
    }
    
    updateBackground(transition: false)
  }
  
  func updateBackground(transition withTransition: Bool = true) {
    let toImage = getImage()
    
    if withTransition {
      UIView.transition(with: self.imageView,
        duration: 5,
        options: UIViewAnimationOptions.transitionCrossDissolve,
        animations: { self.imageView.image = toImage },
        completion: nil)
    } else {
      imageView.image = toImage
    }
  }
  
  fileprivate func getImage() -> UIImage! {
    // Create and return the background image view
    let imageName = self.getImageName()
    return UIImage(named: imageName!)
  }
  
  fileprivate func getImageName() -> String! {
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
