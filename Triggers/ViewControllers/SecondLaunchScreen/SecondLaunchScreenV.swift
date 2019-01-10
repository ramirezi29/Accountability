//
//  SecondLaunchScreenV.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/8/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import MessageUI
import AVFoundation
import ContactsUI

class SecondLaunchScreenV: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    private let locationManger = CLLocationManager()
    private let center = UNUserNotificationCenter.current()
    private let londonLatitude = 51.50998
    private let londonLongitude = -0.1337
    private let desiredRadius = 60.96
    private let londonID = "devMntID"
    private let londonRequestID = "devMntRequestID"
    private let homeSegueID = "segueToHome"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    // MARK: - life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
      
       
        
        // MARK: - Loaction Elments
        locationManger.delegate = self
        
        locationManger.startUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: londonLatitude, longitude: londonLongitude)
        
        let devMountainRegion = CLCircularRegion(center: center, radius: desiredRadius, identifier: londonID)
        
        locationManger.startMonitoring(for: devMountainRegion)
        
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManger.distanceFilter = 10
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: self.homeSegueID, sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


extension SecondLaunchScreenV {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            
            //Test print
            print("\nUsers location is restricted")
            
        case .denied:
            
            //Test print
            print("\nUser denied access to use their location\n")
            
        case .authorizedWhenInUse:
            
            //Test print
            print("\nuser granted authorizedWhenInUse\n")
            
            
        case .authorizedAlways:
            
            //Test print
            print("\nuser selected authorizedAlways\n")
            
        default: break
        }
    }
}

// MARK: - Did Enter Region Location Deleage
extension SecondLaunchScreenV {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        print("🚀🚀🌎 didEnterRegion: User Entered location🌎🚀🚀")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        print("🌎 didStartMonitoringFor: The monitored regions are: \(manager.monitoredRegions)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //NOTE: - Uncomment in order for testing purposes
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //uncomment in order for testing purposes
        print("🌎 didUpdateLocations: locations = \(locValue.latitude) \(locValue.longitude)")
    }
}


// MARK: - Notification didRecieve Delegate
extension SecondLaunchScreenV {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        /*Test print*/
        print("\nNotification item response tap: \(response.notification.request.identifier)")
        
        let sponsorName = UserController.shared.loggedInUser?.userName ?? "Support Person"
        let sponsorPhoneNumber = UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "18006624357"
        let sponosrEmail = UserController.shared.loggedInUser?.sponsorEmail ?? ""
        let sponsorText = UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "“741741" //include “Listen” in text message
        
        defer {
            completionHandler()
        }
        
        //https://www.justthinktwice.gov/facts/what-addiction
        switch response.actionIdentifier {
            //The action that indicates the user explicitly dismissed the notification interface.
        //This action is delivered only if the notification’s category object was configured with the customDismissAction option.
        case UNNotificationDismissActionIdentifier:
            print(" 'X' was tapped")
            // Do something in order to record that the geo fence was crossed but the notification was dismissed
            
        //An action that indicates the user opened the app from the notification interface.
        case UNNotificationDefaultActionIdentifier:
            print("use")
            
        case LocationConstants.telephoneSponsorActionKey:
            print("call the sponsor: \(sponsorName), \(sponsorPhoneNumber) ")
            telephoneSponsor()
            
        case LocationConstants.emailSponsorActionKey:
            print("email \(sponosrEmail)")
            composeEmail()
            
        case LocationConstants.textMessageSponsorActionKey:
            print("Text: \(sponsorName), \(sponsorText)")
            composeTextMessage()
            
        default:
            break
        }
        
    }
}

// MARK: - Email
extension SecondLaunchScreenV: MFMailComposeViewControllerDelegate {
    
    func composeEmail() {
        
        
        //check if device can send mail
        guard MFMailComposeViewController.canSendMail() else {
            
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing E-Mail", alertMessage: "Your device does not support this feature", dismissActionTitle: "OK")
            
            DispatchQueue.main.async {
                self.present(notMailCompatable, animated: true)
            }
            return
        }
        fetchCurrentuser()
        
        let composeEmail = MFMailComposeViewController()
        composeEmail.mailComposeDelegate = self
        composeEmail.setToRecipients(["\(UserController.shared.loggedInUser?.sponsorEmail ?? "")"])
        composeEmail.setSubject("Check-In")
        composeEmail.setMessageBody("Hi there, I just wanted to check in and give you a quick update.", isHTML: false)
        
        DispatchQueue.main.async {
            self.present(composeEmail, animated: true)
        }
    }
    
    func WalkThroughContentVC(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch result {
        case .cancelled:
            print("🐦🐦🐦Cancled email")
        case .failed:
            print("🐦🐦🐦faled")
        case .saved:
            print("🐦🐦🐦mail savied")
        case .sent:
            print("🐦🐦🐦mail saved")
        }
        DispatchQueue.main.async {
            
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Text Message
extension SecondLaunchScreenV: MFMessageComposeViewControllerDelegate {
    
    func composeTextMessage() {
        
        guard MFMessageComposeViewController.canSendText() else {
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing Text Message", alertMessage: "At this time, your device does not support this feature", dismissActionTitle: "OK")
            DispatchQueue.main.async {
                self.present(notMailCompatable, animated: true, completion: nil)
            }
            return
        }
        
        fetchCurrentuser()
        
        let composeText = MFMessageComposeViewController()
        composeText.messageComposeDelegate = self
        
        composeText.recipients = ["\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "")"]
        composeText.body = "Hi \(UserController.shared.loggedInUser?.sponsorName ?? "Friend"),\n\njust wanted to check in and give you an update."
        
        
        DispatchQueue.main.async {
            self.present(composeText, animated: true) {
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}


// MARK: - Telephone
extension SecondLaunchScreenV {
    
    func telephoneSponsor() {
        
        fetchCurrentuser()
        guard let phoneCallURL = URL(string: "telprompt://\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "7142510446")") else {
            let phoneCallError = AlertController.presentAlertControllerWith(alertTitle: "Error Making Phone Call", alertMessage: "Unexpected error please try again later", dismissActionTitle: "OK")
            DispatchQueue.main.async {
                self.present(phoneCallError, animated: true, completion: nil)
            }
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(phoneCallURL)
        }
    }
}

extension SecondLaunchScreenV {
    
    func fetchCurrentuser() {
        UserController.shared.fetchCurrentUser { (success, _) in
            if success {
                guard let loggedInUser = UserController.shared.loggedInUser
                    else { return }
                print(loggedInUser.userName)
                print("\(loggedInUser.aaStep)")
                
            } else {
                print("\nUnable to fetch current user\n")
            }
        }
    }
}
