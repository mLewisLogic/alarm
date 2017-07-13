//
//  MotionMonitor.swift
//  alarm
//
//  Created by Michael Lewis on 3/22/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import CoreMotion
import Foundation

// Monitor the movement of the user by tracking spikes in the accelerometer
// data.

protocol MotionMonitorDelegate {
  func receiveMotionMonitorData(_ intensity: Double)
}

class MotionMonitor: NSObject {

  // Callback delegate for data updates
  var delegate: MotionMonitorDelegate!
  // Keep a reference to the CMMotionManager
  let motionManager = CMMotionManager()
  // Keep the last recorded motion data point for comparison
  var lastMotionData: CMDeviceMotion?

  override init() {
    super.init()
  }

  // Start monitoring for motion changes
  func startMonitoring() {
    if motionManager.isDeviceMotionAvailable {
      motionManager.deviceMotionUpdateInterval = 0.01
      motionManager.startDeviceMotionUpdates(to: OperationQueue.main) {
        (current: CMDeviceMotion!, error: Error!) in

        if let last = self.lastMotionData {
          // Calculate the 3D distance between two CMAcceleration's
          let currentAccel = current.userAcceleration
          let lastAccel = last.userAcceleration
          let distance = pow(
            (
              pow(currentAccel.x - lastAccel.x, 2.0) +
              pow(currentAccel.y - lastAccel.y, 2.0) +
              pow(currentAccel.z - lastAccel.z, 2.0)
            ),
            0.5
          )
          self.delegate.receiveMotionMonitorData(distance)
        }
        // Stash the data for next time around
        self.lastMotionData = current
      }

    }
  }

  // Stop monitoring for motion updates
  func stopMonitoring() {
    motionManager.stopDeviceMotionUpdates()
  }
}
