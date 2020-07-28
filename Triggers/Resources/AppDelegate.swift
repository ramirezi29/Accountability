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
    var reachability: Reachability?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ReachabilityController.sharedReach.activateReachability()
        
        //Notifications Delegate set
        let current = UNUserNotificationCenter.current()
        current.delegate = self
        
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
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0;
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}


