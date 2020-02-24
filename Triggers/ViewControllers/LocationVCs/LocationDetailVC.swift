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


class LocationDetailVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, MKLocalSearchCompleterDelegate {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
            retrieveAnnotations()
        }
    }
    
    //Access user properties
    var user: User?
    
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    private let metersPerHalfMile = 804.672
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private var authorizationStatus = CLLocationManager.authorizationStatus()
    private let desiredRadius = 60.96
    
    
    //NOTE: Trying out a different layout to put the alert constants
    let badAddressNotif = AlertController.presentAlertControllerWith(alertTitle: "Address Not Found", alertMessage: "Sorry, Couldnt not find the specified address", dismissActionTitle: "OK")
    let networkErroNoif = AlertController.presentAlertControllerWith(alertTitle: "Network Error", alertMessage: "Ensure that you are connected to the internet and signed into your iCloud account", dismissActionTitle: "OK")
    
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        UNUserNotificationCenter.current().delegate = self
        toolView.backgroundColor = ColorPallet.offWhite.value
        toolView.layer.cornerRadius = 10
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationDetailVC.hideKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        let longPressMapTap = UILongPressGestureRecognizer(target: self, action: #selector(LocationDetailVC.handleTap(_:)))
        
        longPressMapTap.delegate = self
        longPressMapTap.minimumPressDuration = 0.5
        
        locationManager.delegate = self
        mapViewOutlet.delegate = self
        
        //Map
        mapViewOutlet.showsUserLocation = true
        mapViewOutlet.userTrackingMode = .follow
        mapViewOutlet.showsCompass = true
        locationManager.startUpdatingLocation()
        mapViewOutlet.addGestureRecognizer(longPressMapTap)
        
        addressTextField.delegate = self
        
        //Auto Complete
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.region = mapViewOutlet.region
        
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
    
    func retrieveAnnotations() {
        guard let location = location,
            let latitude = CLLocationDegrees(exactly: location.latitude),
            let longitude = CLLocationDegrees(exactly: location.longitude)
            else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        mapViewOutlet.addAnnotation(pointAnnotation)
        
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerHalfMile, longitudinalMeters: self.metersPerHalfMile)
        self.mapViewOutlet.setRegion(viewRegion, animated: true)
    }
    
    func updateViews() {
        //Update the text fields
        guard let location = location else {return}
        locationTitleTextField.text = location.locationTitle
        addressTextField.text = location.geoCodeAddressString
    }
    
    func searchButtonUI() {
        searchButton.setTitle("Search", for: .normal)
    }
    
    func startShowActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func stopHideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
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
    
    // MARK: - Map Type Display
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
    
    // MARK: - Actions
    @IBAction func mapTypeButtonTapped(_ sender: UIButton) {
        presentMapTypes()
    }
    
    @IBAction func userLocationButtonTapped(_ sender: UIButton) {
        centerMapOnUserLocation()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        let isOnboarded = UserDefaults.standard.bool(forKey: "hasViewedWalkthrough")
        
        if isOnboarded {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // In order to prevent duplicate creations due to delay in pop over
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        DispatchQueue.main.async {
            self.startShowActivityIndicator()
        }
        
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
                    NotificationController.createBasicSobrietyNotificationWithDismiss(contentTitle: "DO NOT ENTER \(locationTitle)", contentBody: "Tap on the My Triggers logo to enter into the app and check-in with \(UserController.shared.loggedInUser?.sponsorName ?? "Your Support Person")", circularRegion: CLCircularRegion(center: self.coordinate!, radius: self.desiredRadius, identifier: "\(locationTitle)"), notifIdentifier: locationTitle)
                    
                    DispatchQueue.main.async {
                        self.stopHideActivityIndicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    DispatchQueue.main.async {
                        self.stopHideActivityIndicator()
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                    }
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    
                    return
                }
            }
        } else {
            LocationController.shared.createNewLocation(geoCodeAddressString: addressLocation, addressTitle: locationTitle, longitude: longitude, latitude: latitude) { (success) in
                if success {
                    // Updated Location Notification with Dismiss Only
                    NotificationController.createBasicSobrietyNotificationWithDismiss(contentTitle: "DO NOT ENTER \(locationTitle)", contentBody: "Tap on the My Triggers logo to enter into the app and check-in with \(UserController.shared.loggedInUser?.sponsorName ?? "Your Support Person")", circularRegion: CLCircularRegion(center: self.coordinate!, radius: self.desiredRadius, identifier: "\(locationTitle)"), notifIdentifier: locationTitle)
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
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
        self.startShowActivityIndicator()
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        guard let addressToSearchFor = addressTextField.toTrimmedString() else {
            
            DispatchQueue.main.async {
                self.stopHideActivityIndicator()
                self.present(self.badAddressNotif, animated: true, completion: nil)
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

//User long Pressed on the Map view
extension LocationDetailVC: CLLocationManagerDelegate {
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: mapViewOutlet)
            
            //touchCoordinate is a CLLocationCoordinate2D
            let touchCoordinate = mapViewOutlet.convert(touchPoint, toCoordinateFrom: mapViewOutlet)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            
            let longPressedLatitude = annotation.coordinate.latitude
            let longPressedLongitude = annotation.coordinate.longitude
            
            mapViewOutlet.removeAnnotations(mapViewOutlet.annotations)
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: longPressedLatitude, longitude: longPressedLongitude)) { (placemarks, error) in
                guard let placemarks = placemarks, let placemark = placemarks.first,
                    
                    let addressComponents = placemark.postalAddress  else {return}
                
                let street = addressComponents.street
                let city = addressComponents.city
                let state = addressComponents.state
                let postalCode = addressComponents.postalCode
                
                //print("\(cnPostalFormatString)")
                //let cnPostalAddressFormatter = CNPostalAddressFormatter()
                //let cnPostalFormatString = cnPostalAddressFormatter.attributedString(from: addressComponents, withDefaultAttributes: [:])
                
                annotation.subtitle = "\(street) \(city), \(state) \(postalCode)"
                
                if !street.isEmpty {
                    
                    self.addressTextField.text = ("\(street) \(city), \(state) \(postalCode)")
                } else {
                    let noStreetAddressFoundAlert = AlertController.presentAlertControllerWith(alertTitle: "No Street Address Found", alertMessage: "Latitude and Longitude were only obtained", dismissActionTitle: "OK")
                    
                    DispatchQueue.main.async {
                        //Present alert
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
                        self.present(self.badAddressNotif, animated: true, completion: nil)
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
        
        print(coordinateRegion.center)
        print(coordinateRegion)
        mapViewOutlet.setRegion(coordinateRegion, animated: true)
    }
    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    //Users location for future use
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //centerMapOnUserLocation()
    }
}

// MARK: - Notification didReceive Delegate
extension LocationDetailVC: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        defer {
            completionHandler()
        }
        switch response.actionIdentifier {
            //The action that indicates the user explicitly dismissed the notification interface
        //This action is delivered only if the notification’s category object was configured with the customDismissAction option.
        case UNNotificationDismissActionIdentifier:
            print( "User tapped dismissed the notification")
            
        //An action that indicates the user opened the app from the notification interface.
        case UNNotificationDefaultActionIdentifier:
            print("user was taken into the app")
        default:
            break
        }
    }
}

