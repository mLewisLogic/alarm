//
//  AppDelegate.swift
//  alarm
//
//  Created by Kevin Farst on 3/4/15.
//  Copyright (c) 2015 Kevin Farst. All rights reserved.
//

import AVFoundation
import CoreData
import UIKit
import MagicalRecord

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Initial setup before we start the UI
        setupMagicalRecord()
        setupAVAudioSession()
        AlarmManager.createInitialAlarms()
        AlarmManager.updateAlarmHelper()
        LocationHelper.enableMonitoring()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = self.window {
            let homeViewController = HomeViewController(
                nibName: "HomeViewController",
                bundle: nil
            )
            
            window.rootViewController = homeViewController
            window.makeKeyAndVisible()
            
            // Request location and recording access
            // We should move this into the onboarding
            LocationHelper.requestLocationAccess()
            SoundMonitor.requestPermissionIfNeeded()
        }
    }


  fileprivate func setupMagicalRecord() {
    MagicalRecord.setupAutoMigratingCoreDataStack()
  }

  fileprivate func setupAVAudioSession() {
    let session = AVAudioSession.sharedInstance()
    
    do {
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    } catch let error {
        NSLog(error.localizedDescription)
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog("applicationWillResignActive")
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog("applicationDidEnterBackground")
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog("applicationWillEnterForeground")
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog("applicationDidBecomeActive")
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    NSLog("applicationWillTerminate")
    MagicalRecord.cleanUp()
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.codepath.alarm" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return (urls[urls.count-1] as NSURL) as URL
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = Bundle.main.url(forResource: "alarm", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("alarm.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    
    do {
        try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
        coordinator = nil
        // Report any error we got.
        let dict = NSMutableDictionary()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        dict[NSUnderlyingErrorKey] = error
        let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as! [AnyHashable: Any])
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(String(describing: error)), \(error.userInfo)")
        abort()
    }

    return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    if let moc = self.managedObjectContext {
      if moc.hasChanges {
        do {
            try moc.save()
        } catch let error {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(String(describing: error))")
            abort()
        }
      }
    }
  }

}

