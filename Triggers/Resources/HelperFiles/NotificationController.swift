//
//  NotificationController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/31/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

class NotificationController {
    
    static func cancelLocalNotificationWith(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    static func createBasicSobrietyNotificationWithDismiss(resourceName: String, extenstionType: String, contentTitle: String, contentBody: String, circularRegion: CLCircularRegion, notifIdentifier: String){
        
        // Action
        let dismissAction = UNNotificationAction(identifier: LocationConstants.dismissActionKey, title: "Dismiss", options: [])
        
        let locationCategory = UNNotificationCategory(identifier: LocationConstants.notifLocationCatergoryKey, actions: [dismissAction], intentIdentifiers: [], options: .customDismissAction)
        
        UNUserNotificationCenter.current().setNotificationCategories([locationCategory])
        
        // Content of the message
        let content = UNMutableNotificationContent()
        content.title = contentTitle
        content.body = contentBody
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = LocationConstants.notifLocationCatergoryKey
        
        // Image
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: extenstionType) else {return}
        do {
            let attachments =  try UNNotificationAttachment(identifier: LocationConstants.resourceKey, url: url, options: [:])
            
            content.attachments = [attachments]
        } catch {
            print("\n\nThere was an error with the attachment in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription)\n\n")
        }
        
        let region = circularRegion
        
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
    
    static func createLocalNotifciationWith(telephoneActionTitle: String, textActionTitle: String, resourceName: String, extenstionType: String, contentTitle: String, contentBody: String, circularRegion: CLCircularRegion, notifIdentifier: String){
        
        // Action
        let dismissAction = UNNotificationAction(identifier: LocationConstants.dismissActionKey, title: "Dismiss", options: [])
        
        let telephoneAction = UNNotificationAction(identifier: LocationConstants.telephoneSponsorActionKey, title: telephoneActionTitle, options: [.authenticationRequired])
        
        let textMessageAction = UNNotificationAction(identifier: LocationConstants.textSponsorActionKey, title: textActionTitle, options: [.authenticationRequired])
        
        let locationCategory = UNNotificationCategory(identifier: LocationConstants.notifLocationCatergoryKey, actions: [dismissAction, telephoneAction, textMessageAction], intentIdentifiers: [], options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([locationCategory])
        
        // Content of the message
        let content = UNMutableNotificationContent()
        content.title = contentTitle
        content.body = contentBody
        content.badge = 1
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = LocationConstants.notifLocationCatergoryKey
        
        // Image
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: extenstionType) else {return}
        do {
            let attachments =  try UNNotificationAttachment(identifier: LocationConstants.resourceKey, url: url, options: [:])
            
            content.attachments = [attachments]
        } catch {
            print("\n\nThere was an error with the attachment in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription)\n\n")
        }
        
        let region = circularRegion
        
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
