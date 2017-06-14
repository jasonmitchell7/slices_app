//
//  AppDelegate.swift
//  Slices
//
//  Created by John Jason Mitchell on 7/22/15.
//  Copyright (c) 2015 John Jason Mitchell. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = styleMgr.colorPrimary
        
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.setBackgroundImage(UIImage(named: "navBG"), for: .default)
        navigationBarAppearance.isTranslucent = true
        navigationBarAppearance.barTintColor = styleMgr.colorLight
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.backgroundColor = styleMgr.colorLight
        navigationBarAppearance.barStyle = .blackTranslucent
        
        return true
    }
    
    
    // Start Notification Code...
    
    func convertDeviceTokenToString(_ deviceToken:Data) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: ">", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: "<", with: "")
        deviceTokenStr = deviceTokenStr.replacingOccurrences(of: " ", with: "")
        
        deviceTokenStr = deviceTokenStr.uppercased()
        
        return deviceTokenStr
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for remote notifications with device token: \(deviceToken)")
        
        let url = ApiHelper.BASE_URL + "/new_device_token"
        
        let tokenStr = convertDeviceTokenToString(deviceToken)
        let params: [String : Any]? = ["token": tokenStr, "type": "apple"]
        
        Alamofire.request(url, method: .post, parameters: params, headers: apiHelper.authTokenHeader()).responseJSON { response in
            switch response.result{
            case .success(let data):
                let json = JSON(data)
                
                print("\(json)")
                
                
            case .failure(let error):
                print("Create new device token failed with error: \(error)")
                print("\(response.result)")
                print("End of device token error.")
                
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Register for remote notifications failed with error: \(error)")
    }
    
    // TODO: Deprecated, see -- "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
    
    // Called when a notification is received and the app is in the
    // foreground (or if the app was in the background and the user clicks on the notification).
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : Any], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        //if let notification = userInfo["aps"] as? NSDictionary,
            //let alert = notification["alert"] as? String {
                //let alertCtrl = UIAlertController(title: "Time Entry", message: alert as String, preferredStyle: UIAlertControllerStyle.Alert)
                //alertCtrl.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // Find the presented VC...
                //var presentedVC = self.window?.rootViewController
                //while (presentedVC!.presentedViewController != nil)  {
                    //presentedVC = presentedVC!.presentedViewController
                //}
                //presentedVC!.presentViewController(alertCtrl, animated: true, completion: nil)
                
                // call the completion handler
                // -- pass in NoData, since no new data was fetched from the server.
                //print("Got notification -- userInfo: \(userInfo["aps"])")
//                completionHandler(UIBackgroundFetchResult.noData)
        //}
    
//    }
    
    // END Notifications Code.

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
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xxx.ProjectName" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Recipes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Slices.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

