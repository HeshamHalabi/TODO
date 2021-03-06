//
//  AppDelegate.swift
//  TODO
//
//  Created by Hesham on 4/26/18.
//  Copyright © 2018 Hesham Al-Halabi. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import CoreDataCloudKit
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // DataController
//    let dataController = DataController(modelName: "TODO")
    let dataController = DataController.shared


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Flurry.startSession("48HYWCVGFDDDC98YSGSV", with: FlurrySessionBuilder
            .init()
            .withCrashReporting(true)
            .withLogLevel(FlurryLogLevelAll))
        
        // pass dataController to category controller
        let tabBarNavigationController = window?.rootViewController as! UITabBarController
        let navigationViewController = tabBarNavigationController.viewControllers![0] as! UINavigationController
        let categotyViewController = navigationViewController.viewControllers[0] as! CategoryViewController
        categotyViewController.dataController = dataController
        
       
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        saveViewContext()
    }


    // MARK: Save view context
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let dict = userInfo as! [String: NSObject]
        let notificaiton = CKNotification(fromRemoteNotificationDictionary: dict)
        
        if notificaiton.subscriptionID! == CloudKitManager.subscriptionID {
            CloudKitManager.shared.fetchCloudChanges()
            completionHandler(.newData)
        }
        
    }
}

