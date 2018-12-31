//
//  AlertController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/27/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import UserNotifications

class AlertController {
    
    static func presentAlertControllerWith(title: String, message: String?) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        [dismissAction].forEach { alertController.addAction($0) }
        
        return alertController
    }
    
//    static func
}

extension AlertController {
    func cancelLocalNotificationWith(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

// present(alertController, animated:  true, completion: nil
