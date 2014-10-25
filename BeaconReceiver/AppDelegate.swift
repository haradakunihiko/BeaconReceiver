//
//  AppDelegate.swift
//  BeaconReceiver
//
//  Created by harada on 2014/10/23.
//  Copyright (c) 2014年 harada. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    let proximityUUID = NSUUID(UUIDString:"00000000-8414-1001-B000-001C4DFB787A")
    var region  = CLBeaconRegion()
    var manager = CLLocationManager()
    var lastDate : NSDate?
    var html = NSString()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        

        region = CLBeaconRegion(proximityUUID: proximityUUID, major: 1, minor: 1, identifier: "jp.co.tzapp.BeaconReceiver")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        //TODO なにこれ？
        region.notifyEntryStateOnDisplay = true
        
        
        manager.delegate = self;
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            //iBeaconによる領域観測を開始する
            println("観測開始")
            manager.startMonitoringForRegion(self.region)
        case .NotDetermined:
            println("許可承認")
            //デバイスに許可を促す
            if(self.manager.respondsToSelector("requestAlwaysAuthorization")){
                //iOS8以降は許可をリクエストする関数をCallする
                // TODO alwaysじゃないほうにする？
                self.manager.requestAlwaysAuthorization()
            }else{
                self.manager.startMonitoringForRegion(self.region)
            }
        case .Restricted, .Denied:
            //デバイスから拒否状態
            println("Restricted")
        }
        
        Parse.setApplicationId("ABDEhfXK7SlwFUKF8hwVyQ1SgkZRw1t9XsQ8H10I", clientKey: "wUOCa57Spig7MRGb4MEdH4VsKFInoltOsBu5b0fD")
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "tzapp.BeaconReceiver" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BeaconReceiver", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BeaconReceiver.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain:"YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
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
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    //MARK: - Remote Notification
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        println("registerusernotificationsetting")
        application.registerForRemoteNotifications();
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("registerforremotenotificationswithdevicetoken");
        
        var installation = PFInstallation.currentInstallation();
        
        println("installation id:%@",installation.installationId);
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually()
    }

    
    // MARK: - Notification
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        var alert = UIAlertView()
        alert.title = "Message"
        alert.message = notification.alertBody
        alert.addButtonWithTitle(notification.alertAction!)
        alert.show()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println(userInfo);
        
        var req = PFObject(withoutDataWithClassName: "DakokuRequest", objectId: userInfo["objectId"] as String);
        
        req.fetchInBackgroundWithBlock { (object:PFObject!, error:NSError!) -> Void in
            if ((error) != nil) {
                completionHandler(UIBackgroundFetchResult.Failed);
            }else {
                self.html = object.objectForKey("html") as NSString
                println("html ")
                println(self.html)
                self.showLocalNotification("dakoku reauest has been accepted.", withMessage: "Thanks!!!")
                //TODO 起動時にはこのhtmlを画面に表示するようにしたい。
                completionHandler(UIBackgroundFetchResult.NewData);
            }
        }
    }
    
    // MARK: - CL
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("didEnter")
        fire();
    }
    
    func fire (){
        var date = NSDate();
        if(lastDate != nil){
            if(NSCalendar.currentCalendar().compareDate(lastDate!, toDate: date, toUnitGranularity: NSCalendarUnit.CalendarUnitDay) == NSComparisonResult.OrderedAscending ){
            }else{
                println("already done for today");
                return;
            }
        }
        lastDate = date;
        
        var central = PFObject(className: "DakokuRequest")
        
        if(NSUserDefaults.standardUserDefaults().stringForKey("id_preference") == nil ||  NSUserDefaults.standardUserDefaults().stringForKey("password_preference") == nil){
            showAlert("error", withMessage: "userid and password for login are required please go to Setting to setup", withButtonTitle: "OK")
            return;
        }
        central["user_id"] = NSUserDefaults.standardUserDefaults().stringForKey("id_preference");
        central["password"] = NSUserDefaults.standardUserDefaults().stringForKey("password_preference");
        central["status"] = 0;
        if(PFInstallation.currentInstallation().installationId == nil){
            showAlert("warning", withMessage: "Could not set up push notification. You will not receive notification for dakoku result.", withButtonTitle: "OK")
        }else{
            central["installationId"] = PFInstallation.currentInstallation().installationId
        }
        
        central.save()
        
        showLocalNotification("Good morning! I sent attendance request for you!", withMessage: "Thanks!")
        
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("didStartMonitoring")
        manager.requestStateForRegion(region);
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("didDeterminStat",state.rawValue)
        switch (state) {
        case .Inside: // リージョン内にいる
            fire();
            break;
        default:
            break;
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == .NotDetermined) {
        } else if(status == .Authorized) {
            manager.startMonitoringForRegion(region)
        } else if(status == .AuthorizedWhenInUse) {
            manager.startMonitoringForRegion(region)
        }
    }
    
    //MARK -util
    
    func showAlert(title: NSString, withMessage message : NSString, withButtonTitle buttonTitle : NSString){
        var alert = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle(buttonTitle)
        alert.show()
    }
    
    
    func showLocalNotification(alertBody: NSString, withMessage alertAction : NSString){
        
        var notification = UILocalNotification()
        notification.fireDate = NSDate()	// すぐに通知したいので現在時刻を取得
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = alertBody
        notification.alertAction = alertAction
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    
    }
}

