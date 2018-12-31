//
//  NotificationController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/31/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import UserNotifications


class NotificationController {
    
    
    
    static func cancelLocalNotificationWith(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
   static func createLocalNotifciation(with notifIdentifier: String){
        
        // Action
        let dismissAction = UNNotificationAction(identifier: LocationConstants.dismissActionKey, title: "Dismiss", options: [])
        
        let telephoneAction = UNNotificationAction(identifier: LocationConstants.telephoneSponsorActionKey, title: "Call Sponsor", options: [.authenticationRequired])
        
        let emailAction = UNNotificationAction(identifier: LocationConstants.emailSponsorActionKey, title: "Email Sponsor", options: [.authenticationRequired])
        
        let category = UNNotificationCategory(identifier: LocationConstants.notifCatergoryKey, actions: [dismissAction, telephoneAction, emailAction], intentIdentifiers: [LocationConstants.dismissActionKey, LocationConstants.telephoneSponsorActionKey, LocationConstants.emailSponsorActionKey], options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        // Content of the message
        let content = UNMutableNotificationContent()
        content.title = "\(String(describing: locationTitleTextField.text)) has been crossed"
        content.body = "Think This Through Do Not Enter and Call your Spnors"
        content.badge = 1
        content.categoryIdentifier = LocationConstants.notifCatergoryKey
        
        let region = CLCircularRegion(center: coordinate!, radius: desiredRadius, identifier: UUID().uuidString)
        
        region.notifyOnEntry = true
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        
        
        let request = UNNotificationRequest(identifier: notifIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("There was an error in \(#function) ; (error) ; \(error.localizedDescription)")
            } else {
                print("\n Successfuly created location based notification")
                
            }
        }
    }
    
}
