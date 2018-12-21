//
//  OnboardingViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class LocationOnboardingVC: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    private let locationManger = CLLocationManager()
    private let center = UNUserNotificationCenter.current()
    private var disableRestrictedAlertBool = false
     private var disableDeniedAlertBool = false
    private let deniedBoolKey = "disabledDeniedAlertBool"
    private let restrictedBoolKey = "disabledRestrictedAlertBool"

    override func viewDidLoad() {
        super.viewDidLoad()

         locationManger.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Notification Permission
        // User Notifcation

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in

            if granted {
                print("Permission for notification was granted by the user")
                UNUserNotificationCenter.current().delegate = self

            }
            // Access granted
            if let error = error {
                print("There was an error in \(#function) ; (error) ; \(error.localizedDescription)")
            }
            // Access to use notification was denied
            if !granted {
                print("Notification Access Denied")
            }

            switch CLLocationManager.authorizationStatus() {

            case .notDetermined:
                //                self.locationManger.requestWhenInUseAuthorization()
                self.locationManger.requestAlwaysAuthorization()

            default:
                break
            }
        }
        locationManger.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:

            if disableRestrictedAlertBool == false {
                disableRestrictedAlertBool = true

                UserDefaults.standard.set(disableRestrictedAlertBool, forKey: restrictedBoolKey)

                //NSLocalizedString is preffered in this case, language does not switch on .localize
                let restrictedAlertController = UIAlertController(title: NSString.localizedUserNotificationString(forKey: "locationServiceRestrictedAlertTitle", arguments: []), message: NSString.localizedUserNotificationString(forKey: "locationServiceRestrictedAlertMessage", arguments: []), preferredStyle: .alert)
                //UIAlertController(title:
                //                    NSLocalizedString("locationServiceRestrictedAlertTitle", comment: ""), message: NSLocalizedString("locationServiceRestrictedAlertMessage", comment: ""), preferredStyle: .alert)
                //dismissTitle
                let dismissAction = UIAlertAction(title: NSString.localizedUserNotificationString(forKey: "dismissLocationActionTitle", arguments: []), style: .cancel) { (alert) in
                    self.presentMainView()
                }

                [dismissAction].forEach { restrictedAlertController.addAction($0)}

                present(restrictedAlertController, animated: true)
            }
            else {
                presentMainView()
            }
            print("\nUsers location is restricted")

        case .denied:

            if disableDeniedAlertBool == false {
                disableDeniedAlertBool = true

                UserDefaults.standard.set(disableDeniedAlertBool, forKey: deniedBoolKey)

                let deniedAlertController = UIAlertController(title: NSString.localizedUserNotificationString(forKey: "locationServiceDeniedAlertTitle", arguments: []), message: NSString.localizedUserNotificationString(forKey: "locationServiceDeniedAlertMessage", arguments: []), preferredStyle: .alert)

                //                    UIAlertController(title: NSLocalizedString("locationServiceDeniedAlertTitle", comment: ""), message: NSLocalizedString("locationServiceDeniedAlertMessage", comment: ""), preferredStyle: .alert)

                let dismissAction = UIAlertAction(title: NSString.localizedUserNotificationString(forKey: "dismissLocationActionTitle", arguments: []), style: .cancel) { (alert) in
                    self.presentMainView()
                }

                [dismissAction].forEach { deniedAlertController.addAction($0)}

                present(deniedAlertController, animated: true)
            }
            else {
                presentMainView()
            }
            print("\nUser denied access to use their location\n")

        case .authorizedWhenInUse:
            print("\nuser granted authorizedWhenInUse\n")
            presentMainView()

        case .authorizedAlways:
            print("\nuser selected authorizedAlways\n")
            presentMainView()
        default: break
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //NOTE: - Uncomment in order for testing purposes
        //print("\n📍viewDidDisappear: \(locationManger.monitoredRegions)🥶")
    }

    func loadUserDefaults() {
        disableDeniedAlertBool = UserDefaults.standard.bool(forKey: deniedBoolKey)
        disableRestrictedAlertBool = UserDefaults.standard.bool(forKey: restrictedBoolKey)
    }

    // Segue programatically to home view controller
    func presentMainView() {
        let homeTVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        present(homeTVC, animated: true, completion: nil)
    }

}
extension LocationOnboardingVC {

    // MARK: - Location Delegate Functions
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        //print("🚀🚀🌎 didEnterRegion: User Entered location🌎🚀🚀")

        scheduleLocationNotification()

    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        //print("🌎 didStartMonitoringFor: The monitored regions are: \(manager.monitoredRegions)")

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //NOTE: - Uncomment in order for testing purposes
        //let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //uncomment in order for testing purposes
        //print("🌎 didUpdateLocations: locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

extension LocationOnboardingVC {

    // MARK: - Notification Delegate Functions for testing
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        print("Test: \(response.notification.request.identifier)")

        defer {
            completionHandler()
        }

        switch response.actionIdentifier {
            //The action that indicates the user explicitly dismissed the notification interface.
        //This action is delivered only if the notification’s category object was configured with the customDismissAction option.
        case UNNotificationDismissActionIdentifier:
            print( "User tapped dismissed the notification")
        //An action that indicates the user opened the app from the notification interface.
        case UNNotificationDefaultActionIdentifier:
            print("user segued into the app")
        default:
            break
        }
    }
}

extension LocationOnboardingVC {

    // MARK: - Location Notification function that gets called when the user enteres the target region

    func scheduleLocationNotification() {

//        let dismissAction = UNNotificationAction(identifier: LocationConstants.dissmissActionKey, title: LocationConstants.locationDismissButtonTitle, options: [])
//
//        let category = UNNotificationCategory(identifier: LocationConstants.categoryKey, actions: [dismissAction], intentIdentifiers: [], options: [])
//        UNUserNotificationCenter.current().setNotificationCategories([category])
//
//        let content = UNMutableNotificationContent()
//        content.title = LocationConstants.locationContentTitle
//        content.body = LocationConstants.locationConentBody
//        content.sound = UNNotificationSound.default
//        content.categoryIdentifier = LocationConstants.categoryKey
//
//        guard let url = Bundle.main.url(forResource: LocationConstants.locationResourceName, withExtension: LocationConstants.pngType) else {return}
//
//        do {
//            let attachments =  try UNNotificationAttachment(identifier: LocationConstants.resourceKey, url: url, options: [:])
//
//            content.attachments = [attachments]
//
//        } catch {
//            print("\n\nThere was an error with the attachment in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription)\n\n")
//        }
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
//
//        let request = UNNotificationRequest(identifier: LocationConstants.requestKey, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if let error = error {
//                print("There was an error in \(#function) ; (error) ; \(error.localizedDescription)")
//            }
//        }
    }
}

