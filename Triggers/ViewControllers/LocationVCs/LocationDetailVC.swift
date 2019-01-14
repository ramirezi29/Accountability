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
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    
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
    private let metersPerMile = 1609.344
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private var authorizationStatus = CLLocationManager.authorizationStatus()
    private let desiredRadius = 60.96
    private let devMntLat = 40.761806
    private let devMntLon = -111.890534
    
    let badAddressNotif = AlertController.presentAlertControllerWith(alertTitle: "Address Not Found", alertMessage: "Sorry, Couldnt not find the specified address", dismissActionTitle: "OK")
    let networkErroNoif = AlertController.presentAlertControllerWith(alertTitle: "Network Error", alertMessage: "Error with your internet connection unable to save", dismissActionTitle: "OK")
    
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Tap guesture for map taps
//        let mapTapGesture = UITapGestureRecognizer(target: self, action:#selector(LocationDetailVC.handleTap(_:)))
        
        let longPressMapTap = UILongPressGestureRecognizer(target: self, action: #selector(LocationDetailVC.handleTap(_:)))
        
        longPressMapTap.delegate = self
        
        longPressMapTap.minimumPressDuration = 0.5

        //Map
        mapViewOutlet.showsUserLocation = true
        let usersLocation = mapViewOutlet.userLocation
        
         
        
        mapViewOutlet.addGestureRecognizer(longPressMapTap)
        
        
        let region = MKCoordinateRegion(center: mapViewOutlet.userLocation.coordinate, latitudinalMeters: 1609.344, longitudinalMeters: 1609.344)
        
        mapViewOutlet.setRegion(region, animated: true)
        
        locationManager.delegate = self
        print(mapViewOutlet.isUserLocationVisible)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        actiivtyViewoutlet.backgroundColor = UIColor.clear
        activityIndicatorOutlet.isHidden = true
        
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
    
    func addAnnotation() {
        guard let location = location,
            let latitude = CLLocationDegrees(exactly: location.latitude),
            let longitude = CLLocationDegrees(exactly: location.longitude)
            else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        mapViewOutlet.addAnnotation(pointAnnotation)
        
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerMile, longitudinalMeters: self.metersPerMile)
        print(mapViewOutlet.isUserLocationVisible)
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
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: self.metersPerMile, longitudinalMeters: self.metersPerMile)
            
            self.mapViewOutlet.setRegion(viewRegion, animated: true)
        }
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        print("\n Save button Taped")
        //Create a location based notification
        guard let locationTitle = locationTitleTextField.text, !locationTitle.isEmpty, let addressLocation = addressTextField.text, !addressLocation.isEmpty else {return}
        
        
        guard let coordianteLatitude = coordinate?.latitude,
            let coordinateLongitude = coordinate?.longitude else {
                
                let coordinateError = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Location", alertMessage: "Ensure that the address is correctly entered", dismissActionTitle: "OK")
                DispatchQueue.main.async {
                    self.present(coordinateError, animated: true, completion: nil)
                }
                return
        }
        
        let latitude = coordianteLatitude
        let longitude = coordinateLongitude
        
        // MARK: - Update
        if let location = location {
            LocationController.shared.updateTargetLocation(location: location, geoCodeAddressString: addressLocation, addressTitle: locationTitle, latitude: latitude, longitude: longitude) { (success) in
                if success {
                    print("🙏🏽 Success updating Location")
                    DispatchQueue.main.async {
                        // Do any UI STuff here that would be triggered by a successful update
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    // prseent UI Alert expalining error
                    DispatchQueue.main.async {
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                        print("\n💀 error with the upating the data 💀")
                    }
                    return
                }
            }
        } else {
            
            LocationController.shared.createNewLocation(geoCodeAddressString: addressLocation, addressTitle: locationTitle, longitude: longitude, latitude: latitude) { (success) in
                if success {
                    
                    NotificationController.createLocalNotifciationWith(contentTitle: "DO NOT ENTER \(locationTitle.capitalized)", contentBody: "Contact your accountability partner \(UserController.shared.loggedInUser?.sponsorName ?? "")", circularRegion: CLCircularRegion(center: self.coordinate!, radius: self.desiredRadius, identifier: UUID().uuidString), notifIdentifier: locationTitle)
                    
                    print("\n🙏🏽Successfully created/saved location🙏🏽")
                    DispatchQueue.main.async {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("\n💀 Error saving Location to Cloud Kit 💀")
                    DispatchQueue.main.async {
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        print("Search Button Tapped")
        self.activityIndicatorOutlet.startAnimating()
        self.activityIndicatorOutlet.isHidden = false
        
        guard let addressToSearchFor = addressTextField.toTrimmedString() else {
            
            DispatchQueue.main.async {
                self.activityIndicatorOutlet.stopAnimating()
                self.activityIndicatorOutlet.isHidden = true
                //present UI Alert Controller
                self.present(self.badAddressNotif, animated: true, completion: nil)
                
                print("Invalid Address enetered")
            }
            
            return
        }
        
        addressTextField.resignFirstResponder()
        showAddressOnMap(address: addressToSearchFor)
        
        DispatchQueue.main.async {
            self.activityIndicatorOutlet.stopAnimating()
            self.activityIndicatorOutlet.isHidden = true
        }
        
    }
}

extension LocationDetailVC {
    
    func searchButtonUI() {
        
        searchButton.setTitle("Search", for: .normal)
    }
}


extension LocationDetailVC: CLLocationManagerDelegate {
    
    
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: mapViewOutlet)
            
            //touchCoordinate is a CLLocationCoordinate2D
            let touchCoordinate = mapViewOutlet.convert(touchPoint, toCoordinateFrom: mapViewOutlet)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "My Trigger"
          
            
            // what you annotatded Long and Lat
            let longPressedLongitude = annotation.coordinate.longitude
            let longPressedLatitude = annotation.coordinate.latitude
            
            print("\(touchCoordinate)")
            mapViewOutlet.removeAnnotations(mapViewOutlet.annotations)
            mapViewOutlet.addAnnotation(annotation) //drops the pin
            
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(CLLocation(latitude: longPressedLatitude, longitude: longPressedLongitude)) { (placemarks, error) in
                guard let placemarks = placemarks, let placemark = placemarks.first else { return }
                //                placemark.locality the city
                // this location address has the address
                
                
                
                guard let addressComponents = placemark.postalAddress  else {return}
                
                let street = addressComponents.street
                let city = addressComponents.city
                let state = addressComponents.state
                let postalCode = addressComponents.postalCode
                
                let cnPostalAddressFormatter = CNPostalAddressFormatter()
                
                let cnPostalFormatString = cnPostalAddressFormatter.attributedString(from: addressComponents, withDefaultAttributes: [:])
                
                  annotation.subtitle = "\(street) \(city), \(state) \(postalCode)"
                
                print("\(cnPostalFormatString)")
                print("\(street) \(city), \(state) \(postalCode)")
                
                self.addressTextField.text = ("\(street) \(city), \(state) \(postalCode)")
            }
        }
    }
}


extension LocationDetailVC: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersPerMile, longitudinalMeters: metersPerMile)
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
        centerMapOnUserLocation()
    }
}
