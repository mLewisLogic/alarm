//
//  LocationHelper.swift
//  alarm
//
//  Created by Michael Lewis on 3/15/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import CoreLocation
import Foundation


// Stash a singleton global instance
private let _locationHelper = LocationHelper()

class LocationHelper: NSObject, CLLocationManagerDelegate {

  var isMonitoringLocation: Bool
  let locationManager: CLLocationManager
  var latestLocation: CLLocation?

  override init() {
    isMonitoringLocation = false
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

    // Call the super initializer before setting up the degelate
    super.init()
    locationManager.delegate = self
  }

  // Create and hold onto a singleton instance of this class
  class var singleton: LocationHelper {
    return _locationHelper
  }


  /* Public interface */

  // Do we need to ask the user for authorization?
  class func isAccessNeeded() -> Bool {
    return .NotDetermined == singleton.authorizationStatus()
  }

  // Set up monitoring if the user has already approved the app
  class func enableMonitoring() {
    if (!isAccessNeeded()) {
      singleton.setupLocationMonitoring()
    }
  }

  // If needed, request access
  class func requestLocationAccess() {
    if (isAccessNeeded()) {
      singleton.locationManager.requestAlwaysAuthorization()
    }
  }


  /* Location update handler functions */
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    latestLocation = locations.last as? CLLocation
    NSLog("locationManager: didUpdateLocations: \(latestLocation?.description)")
  }

  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    NSLog("locationManager: didFailWithError: \(error.description)")
  }

  func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
    NSLog("locationManager: didFinishDeferredUpdatesWithError: \(error.description)")
  }

  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    NSLog("locationManager: auth status changed to: \(status.rawValue)")
    setupLocationMonitoring()
  }



  /* Private */

  // Set up location monitoring. Try to use the lightest power methods first
  // and fall back to more energy intensive methods if needed.
  private func setupLocationMonitoring() {
    // Early return if we already have monitoring setup
    if (isMonitoringLocation) {
      return
    }

    // Make sure we have appropriate access before
    // enabling location monitoring
    if (accessIsAuthorized()) {
      // Stash the current location
      latestLocation = locationManager.location
      // Cascade down our location provider hierarchy
      if (CLLocationManager.significantLocationChangeMonitoringAvailable() && .AuthorizedAlways == authorizationStatus()) {
        NSLog("Setting up significant location change monitoring")
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoringLocation = true
      } else if (CLLocationManager.locationServicesEnabled()) {
        if (CLLocationManager.deferredLocationUpdatesAvailable()) {
          NSLog("Setting up deferred location updating")
          // If allowed, defer updates unless the location has changed 
          // by more than 5km, or is more than 24 hours stale.
          locationManager.allowDeferredLocationUpdatesUntilTraveled(5000.0, timeout: 24.0 * 60.0 * 60.0)
        }
        NSLog("Enabling location monitoring")
        locationManager.startUpdatingLocation()
        isMonitoringLocation = true
      } else {
        NSLog("Location monitoring: cannot setup.")
      }
    } else {
      NSLog("Location monitoring: cannot setup. status = \(authorizationStatus().rawValue)")
    }
  }

  // Disable location monitoring
  private func teardownLocationMonitoring() {
    locationManager.stopMonitoringSignificantLocationChanges()
    locationManager.stopUpdatingLocation()
    isMonitoringLocation = false
  }

  // Has access specifically been granted?
  private func accessIsAuthorized() -> Bool {
    let status = authorizationStatus()
    switch status {
    case .AuthorizedAlways:
      return true
    default:
      return false
    }
  }

  // Has access specifically been restricted?
  private func accessIsRestricted() -> Bool {
    let status = authorizationStatus()
    switch status {
    case .Denied, .Restricted:
      return true
    default:
      return false
    }
  }

  private func authorizationStatus() -> CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
}