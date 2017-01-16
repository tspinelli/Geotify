//
//  AppDelegate.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  let motionManager = CMMotionManager()
  var networkTimer : Timer?
  var lastTransmitTime = Date()
  var triggerNetworkFromMotion = false
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    if (triggerNetworkFromMotion) {
      if motionManager.isAccelerometerAvailable {
        motionManager.accelerometerUpdateInterval = 0.04
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
          [weak self] (data: CMAccelerometerData?, error: Error?) in
          if let timeSinceLastTransmit = self?.lastTransmitTime.timeIntervalSinceNow {
            if (timeSinceLastTransmit < -30) {
              self?.sendNetworkGetAndNotify()
              self?.lastTransmitTime = Date()
            }
          }
        }
      }
    } else {
      networkTimer = Timer.scheduledTimer(timeInterval:30, target:self, selector:#selector(self.sendNetworkGetAndNotify), userInfo: nil, repeats: true)
    }
    
    locationManager.delegate = self                // Add this line
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers// kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()   // And this one
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.allowsBackgroundLocationUpdates = true
    
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.startUpdatingLocation()

    application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound,.alert, .badge], categories: nil))
    UIApplication.shared.cancelAllLocalNotifications()
    
    
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func notefromRegionIdentifier(_ identifier: String) -> String? {
    if let savedItems = UserDefaults.standard.array(forKey: kSavedItemsKey) {
      for savedItem in savedItems {
        if let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification {
          if geotification.identifier == identifier {
            return geotification.note
          }
        }
      }
    }
    return nil
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

  }
  
  func locationManager(_ manager: CLLocationManager, status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
      break
    case .authorizedWhenInUse:
      locationManager.startUpdatingLocation()
      break
    case .authorizedAlways:
      locationManager.startUpdatingLocation()
      break
    case .restricted:
      // restricted by e.g. parental controls. User can't enable Location Services
      break
    case .denied:
      // user denied your app access to Location Services, but can grant access from Settings.app
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers// kCLLocationAccuracyBest
      locationManager.stopUpdatingLocation()
      if UIApplication.shared.applicationState == .active {
        let message = "\(notefromRegionIdentifier(region.identifier)) set GPS to LOW precision"
        if let viewController = window?.rootViewController {
          showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
        }
      } else {
        // Otherwise present a local notification
        let notification = UILocalNotification()
        notification.alertTitle = "Enter Region"
        notification.alertBody = "\(notefromRegionIdentifier(region.identifier)) set GPS to LOW precision"
        UIApplication.shared.presentLocalNotificationNow(notification)
      }
      
//      handleRegionEvent(region)
    }
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
      
      if UIApplication.shared.applicationState == .active {
        let message = "\(notefromRegionIdentifier(region.identifier)) set GPS to HIGH precision"
        if let viewController = window?.rootViewController {
          showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
        }
      } else {
        // Otherwise present a local notification
        let notification = UILocalNotification()
        notification.alertTitle = "Exit Region"
        notification.alertBody = "\(notefromRegionIdentifier(region.identifier)) set GPS to HIGH precision"
        UIApplication.shared.presentLocalNotificationNow(notification)
      }
//      handleRegionEvent(region)
    }
  }
  
  func sendNetworkGetAndNotify () {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")
    
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      var message : String
      if error == nil {
        message = "Still networking"
      } else {
        message = "Error: \(error!.localizedDescription)"
      }

      // create a corresponding local notification
      let notification = UILocalNotification()
      notification.alertTitle = "Network"
      notification.alertBody = message
      UIApplication.shared.presentLocalNotificationNow(notification)
    }
    
    task.resume()
  }
  
}

