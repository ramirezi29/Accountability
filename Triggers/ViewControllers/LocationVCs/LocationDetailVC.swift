//
//  LocationViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications
import AVFoundation
import CloudKit
import CoreLocation
import MessageUI
import ContactsUI


class LocationDetailVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var enterTitleLabel: UILabel!
    @IBOutlet weak var enterAddressLabel: UILabel!
    @IBOutlet weak var locationTitleTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    
    @IBOutlet weak var actiivtyViewoutlet: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //View
    @IBOutlet weak var toolView: UIView!
    
    //Tools
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var userLoactionButton: UIButton!
    
    //Mark: - Landing Pad
    var location: Location? {
        didSet {
            loadViewIfNeeded()
            addAnnotation()
        }
    }
    var user: User?
    
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    private let metersPerHalfMile = 804.672
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private var authorizationStatus = CLLocationManager.authorizationStatus()
    private let desiredRadius = 60.96
    private let devMntLat = 40.761806
    private let devMntLon = -111.890534
    private let bannerResouceName = "myTriggersBannerFinalLogo"
    private let resourceType = "png"
    
    let badAddressNotif = AlertController.presentAlertControllerWith(alertTitle: "Address Not Found", alertMessage: "Sorry, Couldnt not find the specified address", dismissActionTitle: "OK")
    let networkErroNoif = AlertController.presentAlertControllerWith(alertTitle: "Network Error", alertMessage: "Error with your internet connection unable to save", dismissActionTitle: "OK")
    
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        UNUserNotificationCenter.current().delegate = self
        
        toolView.backgroundColor = MyColor.offWhite.value
        
        toolView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationDetailVC.hideKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        //Tap guesture for map taps
        //        let mapTapGesture = UITapGestureRecognizer(target: self, action:#selector(LocationDetailVC.handleTap(_:)))
        
        let longPressMapTap = UILongPressGestureRecognizer(target: self, action: #selector(LocationDetailVC.handleTap(_:)))
        
        longPressMapTap.delegate = self
        
        longPressMapTap.minimumPressDuration = 0.5
        
        //Location and Map Delegate
        locationManager.delegate = self
        mapViewOutlet.delegate = self
        
        //Map
        
        mapViewOutlet.showsUserLocation = true
        mapViewOutlet.userTrackingMode = .follow
        mapViewOutlet.showsCompass = true
        locationManager.startUpdatingLocation()
        
        
        //        let usersLocation = mapViewOutlet.userLocation
        
        
        
        mapViewOutlet.addGestureRecognizer(longPressMapTap)
        
        
        //        let region = MKCoordinateRegion(center: mapViewOutlet.userLocation.coordinate, latitudinalMeters: , longitudinalMeters: 1609.344)
        //
        //        mapViewOutlet.setRegion(region, animated: true)
        
        
        print(mapViewOutlet.isUserLocationVisible)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //Activity Indicator
        actiivtyViewoutlet.backgroundColor = UIColor.clear
        activityIndicator.isHidden = true
        
        //Button UI
        searchButtonUI()
        
        //Background UI
        view.addVerticalGradientLayer(topColor: UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        loadViewIfNeeded()
        updateViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func addAnnotation() {
        guard let location = location,
            let latitude = CLLocationDegrees(exactly: location.latitude),
            let longitude = CLLocationDegrees(exactly: location.longitude)
            else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        mapViewOutlet.addAnnotation(pointAnnotation)
        
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerHalfMile, longitudinalMeters: self.metersPerHalfMile)
        print("Is user location visable \(mapViewOutlet.isUserLocationVisible). Clled in the add annotation func")
        self.mapViewOutlet.setRegion(viewRegion, animated: true)
        
    }
    
    func updateViews() {
        
        //Update the text fields
        guard let location = location else {return}
        locationTitleTextField.text = location.locationTitle
        addressTextField.text = location.geoCodeAddressString
    }
    
    private func showAddressOnMap(address: String) {
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let `self` = self else { return }
            
            guard error == nil else {
                
                return
            }
            
            guard let placemark = placemarks?.first,
                let coordinate = placemark.location?.coordinate else {
                    
                    return
            }
            
            self.coordinate = coordinate
            
            if let annotation = self.annotation {
                self.mapViewOutlet.removeAnnotation(annotation)
            }
            
            self.annotation = MKPointAnnotation()
            self.annotation!.coordinate = coordinate
            
            // This is going to be the data associated with the location
            if let thoroughfare = placemark.thoroughfare {
                if let subThoroughfare = placemark.subThoroughfare {
                    self.annotation!.title = "\(subThoroughfare) \(thoroughfare)"
                } else {
                    self.annotation!.title = thoroughfare
                }
            } else {
                self.annotation!.title = address
            }
            
            self.mapViewOutlet.addAnnotation(self.annotation!)
            
            // the region around the annotation
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerHalfMile, longitudinalMeters: self.metersPerHalfMile)
            
            self.mapViewOutlet.setRegion(viewRegion, animated: true)
        }
    }
    
    @IBAction func mapTypeButtonTapped(_ sender: UIButton) {
        presentMapTypes()
    }
    
    
    @IBAction func userLocationButtonTapped(_ sender: UIButton) {
        centerMapOnUserLocation()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        // In order to prevent duplicate creations due to delay in pop over
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        DispatchQueue.main.async {
            self.startShowActivityIndicator()
        }
        
        print("\n Save button Taped")
        //Create a location based notification
        
        //Guard against either textfield being empty
        guard let locationTitle = locationTitleTextField.text, !locationTitle.isEmpty, let addressLocation = addressTextField.text, !addressLocation.isEmpty else {
            
            navigationItem.rightBarButtonItem?.isEnabled = true
            
            let textFieldError = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Location", alertMessage: "You must enter a location address and title before saving", dismissActionTitle: "OK")
            
            DispatchQueue.main.async {
                
                self.stopHideActivityIndicator()
                self.present(textFieldError, animated: true, completion: nil)
            }
            return
        }
        
        //Guard against the latitude or longitude being nil
        guard let coordianteLatitude = coordinate?.latitude,
            let coordinateLongitude = coordinate?.longitude else {
                
                let coordinateError = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Location", alertMessage: "Ensure that the address is correctly entered", dismissActionTitle: "OK")
                
                DispatchQueue.main.async {
                    
                    self.stopHideActivityIndicator()
                    self.present(coordinateError, animated: true, completion: nil)
                }
                navigationItem.rightBarButtonItem?.isEnabled = true
                return
        }
        
        let latitude = coordianteLatitude
        let longitude = coordinateLongitude
        
        // MARK: - Update current location
        if let location = location {
            LocationController.shared.updateTargetLocation(location: location, geoCodeAddressString: addressLocation, addressTitle: locationTitle, latitude: latitude, longitude: longitude) { (success) in
                if success {
                    
                    //Cancel notification based on the original location title
                    NotificationController.cancelLocalNotificationWith(identifier: location.locationTitle)
                    
                    //Create new notification with identifier as the new location title
                    NotificationController.createBasicSobrietyNotificationWithDismiss(resourceName: self.bannerResouceName, extenstionType: self.resourceType, contentTitle: "DO NOT ENTER \(locationTitle.capitalized)", contentBody: "Tap on the My Triggers logo to enter into the app and check-in with \(UserController.shared.loggedInUser?.sponsorName ?? "Your Support Person")", circularRegion: CLCircularRegion(center: self.coordinate!, radius: self.desiredRadius, identifier: "\(locationTitle)"), notifIdentifier: locationTitle)
                    
                    //Test Print
                    print("🙏🏽 Success updating Location")
                    
                    DispatchQueue.main.async {
                        self.stopHideActivityIndicator()
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    // prseent UI Alert expalining error
                    DispatchQueue.main.async {
                        
                        self.stopHideActivityIndicator()
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                        print("\n💀 error with the upating the data 💀")
                    }
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
            }
        } else {
            
            //Creating New Location
            LocationController.shared.createNewLocation(geoCodeAddressString: addressLocation, addressTitle: locationTitle, longitude: longitude, latitude: latitude) { (success) in
                if success {
                    
                    // Updated Location Notification with Dismiss Only
                    
                    NotificationController.createBasicSobrietyNotificationWithDismiss(resourceName: self.bannerResouceName, extenstionType: self.resourceType, contentTitle: "DO NOT ENTER \(locationTitle.capitalized)", contentBody: "Tap on the My Triggers logo to enter into the app and check-in with \(UserController.shared.loggedInUser?.sponsorName ?? "Your Support Person")", circularRegion: CLCircularRegion(center: self.coordinate!, radius: self.desiredRadius, identifier: "\(locationTitle)"), notifIdentifier: locationTitle)
                    
                    
                    
                    print("\n🙏🏽Successfully created/saved location🙏🏽")
                    DispatchQueue.main.async {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("\n💀 Error saving Location to Cloud Kit 💀")
                    DispatchQueue.main.async {
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                    }
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    return
                }
            }
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        print("Search Button Tapped")
        self.startShowActivityIndicator()
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        guard let addressToSearchFor = addressTextField.toTrimmedString() else {
            
            DispatchQueue.main.async {
                self.stopHideActivityIndicator()
                //present UI Alert Controller
                self.present(self.badAddressNotif, animated: true, completion: nil)
                
                print("Invalid Address enetered")
            }
            
            return
        }
        
        addressTextField.resignFirstResponder()
        showAddressOnMap(address: addressToSearchFor)
        
        DispatchQueue.main.async {
            self.stopHideActivityIndicator()
        }
        
    }
}

extension LocationDetailVC {
    
    func searchButtonUI() {
        
        searchButton.setTitle("Search", for: .normal)
    }
}

// Long Press on Map
extension LocationDetailVC: CLLocationManagerDelegate {
    
    
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: mapViewOutlet)
            
            //touchCoordinate is a CLLocationCoordinate2D
            let touchCoordinate = mapViewOutlet.convert(touchPoint, toCoordinateFrom: mapViewOutlet)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            //            annotation.title = "My Trigger"
            
            
            // what you annotatded Long and Lat
            let longPressedLatitude = annotation.coordinate.latitude
            let longPressedLongitude = annotation.coordinate.longitude
            
            print("\(touchCoordinate)")
            mapViewOutlet.removeAnnotations(mapViewOutlet.annotations)
            //            mapViewOutlet.addAnnotation(annotation) //drops the pin
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: longPressedLatitude, longitude: longPressedLongitude)) { (placemarks, error) in
                guard let placemarks = placemarks, let placemark = placemarks.first else { return }
                //                placemark.locality the city
                // this location address has the address
                
                guard let addressComponents = placemark.postalAddress  else {return}
                
                //Long and Lat
                let longPressedLatAndLongString = "(\(longPressedLatitude)\(longPressedLongitude))"
                
                
                print("This is the Lat and Long that was long pressed \(longPressedLatAndLongString)")
                
                //Readable Components
                let street = addressComponents.street
                let city = addressComponents.city
                let state = addressComponents.state
                let postalCode = addressComponents.postalCode
                
                let cnPostalAddressFormatter = CNPostalAddressFormatter()
                
                let cnPostalFormatString = cnPostalAddressFormatter.attributedString(from: addressComponents, withDefaultAttributes: [:])
                
                annotation.subtitle = "\(street) \(city), \(state) \(postalCode)"
                
                print("\(cnPostalFormatString)")
                print("\(street) \(city), \(state) \(postalCode)")
                
                if !street.isEmpty {
                    
                    self.addressTextField.text = ("\(street) \(city), \(state) \(postalCode)")
                } else {
                    let noStreetAddressFoundAlert = AlertController.presentAlertControllerWith(alertTitle: "No Street Address Found", alertMessage: "Latitude and Longitude were only obtained", dismissActionTitle: "OK")
                    DispatchQueue.main.async {
                        self.present(noStreetAddressFoundAlert, animated: true, completion: nil)
                    }
                    self.addressTextField.text = ("\(longPressedLatitude), \(longPressedLongitude)")
                }
                
                self.activityIndicator.startAnimating()
                self.activityIndicator.isHidden = false
                
                guard let addressToSearchFor = self.addressTextField.toTrimmedString() else {
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        //present UI Alert Controller
                        self.present(self.badAddressNotif, animated: true, completion: nil)
                        
                        print("Invalid Address enetered")
                    }
                    
                    return
                }
                
                
                self.showAddressOnMap(address: addressToSearchFor)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                
            }
        }
    }
}



extension LocationDetailVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersPerHalfMile, longitudinalMeters: metersPerHalfMile)
        mapViewOutlet.setRegion(coordinateRegion, animated: true)
    }
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        centerMapOnUserLocation()
    }
}

// MARK: - Map Action Sheet func
extension LocationDetailVC {
    
    func presentMapTypes() {
        let mapTypesAlertController = AlertController.presentActionSheetAlertControllerWith(alertTitle: nil, alertMessage: nil, dismissActionTitle: "Cancel")
        
        let normalMapSelection = UIAlertAction(title: "Normal", style: .default) { (_) in
            self.mapViewOutlet.mapType = MKMapType.standard
        }
        let satelliteMapSelection = UIAlertAction(title: "Satellite", style: .default) { (_) in
            self.mapViewOutlet.mapType = MKMapType.satellite
        }
        let hybridMapSelection = UIAlertAction(title: "Hybrid", style: .default) { (_) in
            self.mapViewOutlet.mapType = MKMapType.hybrid
        }
        
        [normalMapSelection, satelliteMapSelection, hybridMapSelection].forEach { mapTypesAlertController.addAction($0)}
        
        DispatchQueue.main.async {
            mapTypesAlertController.popoverPresentationController?.sourceView = self.view
            mapTypesAlertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            mapTypesAlertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            self.present(mapTypesAlertController, animated: true, completion: nil)
        }
    }
}


extension LocationDetailVC {
    
    func startShowActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func stopHideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}

//Notification didReceive Delegate
extension LocationDetailVC: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        //Not sure if this is needed
        //        let userInfo = response.notification.request.content.userInfo
        //        let textMessageAction = userInfo[LocationConstants.textSponsorActionKey]
        //        let telephoneAction = userInfo[LocationConstants.telephoneSponsorActionKey]
        
        //This is the option that was selected
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
            //
            //        case LocationConstants.telephoneSponsorActionKey:
            //            telephoneSponsor()
            //
            //        case LocationConstants.textSponsorActionKey:
        //            composeTextMessage()
        default:
            break
        }
    }
}


//// MARK: - Text Message
//extension LocationDetailVC: MFMessageComposeViewControllerDelegate {
//
//    func composeTextMessage() {
//
//        guard MFMessageComposeViewController.canSendText() else {
//            // DO some UI to show that an email cant be sent
//            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing Text Message", alertMessage: "At this time, your device does not support this feature", dismissActionTitle: "OK")
//            DispatchQueue.main.async {
//                self.present(notMailCompatable, animated: true, completion: nil)
//            }
//            return
//        }
//
//        fetchCurrentuser()
//
//        let composeText = MFMessageComposeViewController()
//        composeText.messageComposeDelegate = self
//
//        composeText.recipients = ["\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "")"]
//        composeText.body = "Hi \(UserController.shared.loggedInUser?.sponsorName ?? "Friend"),\n\njust wanted to check in and give you an update."
//
//
//        DispatchQueue.main.async {
//            self.present(composeText, animated: true) {
//            }
//        }
//    }
//
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//
//        switch result {
//        case .cancelled:
//            controller.dismiss(animated: true, completion: nil)
//        case .failed:
//            controller.dismiss(animated: true, completion: nil)
//        case .sent:
//            controller.dismiss(animated: true, completion: nil)
//        default:
//            break
//        }
//    }
//}
//
//
//// MARK: - Telephone
//extension LocationDetailVC {
//
//    func telephoneSponsor() {
//
//        fetchCurrentuser()
//        guard let phoneCallURL = URL(string: "telprompt://\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "7142510446")") else {
//            let phoneCallError = AlertController.presentAlertControllerWith(alertTitle: "Error Making Phone Call", alertMessage: "Unexpected error please try again later", dismissActionTitle: "OK")
//            DispatchQueue.main.async {
//                self.present(phoneCallError, animated: true, completion: nil)
//            }
//            return
//        }
//        DispatchQueue.main.async {
//            UIApplication.shared.open(phoneCallURL)
//        }
//    }
//}

extension LocationDetailVC {
    
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



