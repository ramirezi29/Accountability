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


class LocationDetailVC: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var enterAddressLabel: UILabel!
    @IBOutlet weak var enterTitleLabel: UILabel!
    @IBOutlet weak var locationTitleTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actiivtyViewoutlet: UIView!
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    
    //Mark: - Landing Pad
    var location: Location?
    
    private let geocoder = CLGeocoder()
    
    private let metersPerMile = 1609.344
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private let desiredRadius = 60.96
    private let devMntLat = 40.761806
    private let devMntLon = -111.890534
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actiivtyViewoutlet.backgroundColor = UIColor.clear
        activityIndicatorOutlet.isHidden = true
     
        //Background UI
        view.addVerticalGradientLayer(topColor: UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        //
        loadViewIfNeeded()
        updateViews()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
            //      placemarks?.first?.location?.coordinate.la
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
    

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        print("\n Save button Taped")
        //Create a location based notification
        createLocalNotifciation()
        
        guard let location = location else {
            print("\n location was nil: in the save button tapped func: -> guard let location = location else\n")
            return}
        
        guard let locationTitle = locationTitleTextField.text, !locationTitle.isEmpty, let addressLocation = addressTextField.text, !addressLocation.isEmpty else {return}
        
        let lat = coordinate?.latitude ?? devMntLat
        let long = coordinate?.longitude ?? devMntLon
        
        if let loggedInUser = UserController.shared.loggedInUser {
            LocationController.shared.updateTargetLocation(location: location, geoCodeAddressString: addressLocation, addressTitle: locationTitle, latitude: lat, longitude: long) { (success) in
                if success {
                    print("🙏🏽 Success updating Location")
                    
                }
            }
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        self.activityIndicatorOutlet.startAnimating()
        self.activityIndicatorOutlet.isHidden = false
        
        guard let addressToSearchFor = addressTextField.toTrimmedString() else {
            
            
            DispatchQueue.main.async {
                self.activityIndicatorOutlet.stopAnimating()
                self.activityIndicatorOutlet.isHidden = true
                //present UI Alert Controller
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
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LocationDetailVC {
    func createLocalNotifciation(){
        
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
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("There was an error in \(#function) ; (error) ; \(error.localizedDescription)")
            } else {
                print("\n Successfuly created location based notification")
            }
        }
    }
}
