//
//  AppDelegate.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate  {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Notifications Delegate set
        let current = UNUserNotificationCenter.current()
        current.delegate = self
        
        //Declare the actions
//        let dismissAction = UNNotificationAction(identifier: LocationConstants.dismissActionKey, title: "Dismiss", options: [])
//
//        let telephoneAction = UNNotificationAction(identifier: LocationConstants.telephoneSponsorActionKey, title: "Call Support Person", options: [.authenticationRequired])
//
//        let textMessageAction = UNNotificationAction(identifier: LocationConstants.textSponsorActionKey, title: "Text Support Person", options: [.authenticationRequired])
//
//        let locationCategory = UNNotificationCategory(identifier: LocationConstants.notifLocationCatergoryKey, actions: [dismissAction, telephoneAction, textMessageAction], intentIdentifiers: [], options: .customDismissAction)
//
//        UNUserNotificationCenter.current().setNotificationCategories([locationCategory])
        
        //Onboarding screen check
        window = UIWindow()
        
        let isOnboarded = UserDefaults.standard.bool(forKey: StoryboardConstants.isOnBoardedBool)
        
        if isOnboarded {
            let storyboard = UIStoryboard(name: StoryboardConstants.mainStoryboard, bundle: nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
        } else {
            let storyboard = UIStoryboard(name: StoryboardConstants.onBoardingStoryBoard, bundle: nil)
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        UserController.shared.fetchCurrentUser { (_, _) in
            
        }
        
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0;
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        //Run this last
//        defer {
//            completionHandler()
//        }
//
//        switch response.actionIdentifier {
//            //The action that indicates the user explicitly dismissed the notification interface.
//        //This action is delivered only if the notification’s category object was configured with the customDismissAction option.
//        case UNNotificationDismissActionIdentifier:
//            print( "User tapped dismissed the notification")
//            //
//        //An action that indicates the user opened the app from the notification interface.
//        case UNNotificationDefaultActionIdentifier:
//            print("user segued into the app")
//
//        case LocationConstants.telephoneSponsorActionKey:
//            print("User selected the telephone option ")
//            //call feature
//        case LocationConstants.textSponsorActionKey:
//            print("user selected the text option ")
//            //text feature
//        default:
//            break
//        }
//    }
}

