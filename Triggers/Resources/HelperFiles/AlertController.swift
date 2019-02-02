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
    
    static func presentAlertControllerWith(alertTitle: String, alertMessage: String?, dismissActionTitle: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        
        return alertController
    }
    
    
    static func presentActionSheetAlertControllerWith(alertTitle: String?, alertMessage: String?, dismissActionTitle: String) -> UIAlertController {
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .actionSheet)
        
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        
        return alertController
    }
}

extension AlertController {
    func cancelLocalNotificationWith(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

extension AlertController {
    
    func addFolderAlertControllerWith(alertTitle: String, alertMessage: String, dismissTitle: String, saveTitle: String, completion: @escaping (Bool) -> Void) -> UIAlertController {
        
        var folderNameTextField: UITextField?
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addTextField { (folderNameField) in
            folderNameField.placeholder = "Enter Folder Name"
            
            folderNameTextField = folderNameField
        }
        
        let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: saveTitle, style: .default) { (_) in
            
            guard let folderName = folderNameTextField?.text, !folderName.isEmpty
                else {return}
            
            
            FolderController.shared.createNewFolder(folderTitle: folderName, completion: { (success) in
                if success {
                    completion(true)
                }
            })
        }
        [dismissAction, saveAction].forEach { alertController.addAction($0) }
        
        return alertController
    }
}

// present(alertController, animated:  true, completion: nil    [dismissAction].forEach { alertController.addAction($0) }
