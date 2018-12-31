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

class LocationDetailVC: UIViewController {
    
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
    var location: Location?
    
    private let geocoder = CLGeocoder()
    
    private let metersPerMile = 1609.344
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private let desiredRadius = 60.96
    private let devMntLat = 40.761806
    private let devMntLon = -111.890534
    let badAddressNotif = AlertController.presentAlertControllerWith(title: "Address Not Found", message: "Sorry, Couldnt not find the specified address")
    let networkErroNoif = AlertController.presentAlertControllerWith(title: "Network Error", message: "Error with your internet connection unable to save")
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
    
 
    @IBAction func backButtonTapped(_ sender: Any) {
   dismiss(animated: true, completion: nil)
    }
    

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        print("\n Save button Taped")
        //Create a location based notification
        
        
        //        guard let location = location else {
        //            print("\n location was nil: in the save button tapped func: -> guard let location = location else\n")
        //            return}
        
        guard let locationTitle = locationTitleTextField.text, !locationTitle.isEmpty, let addressLocation = addressTextField.text, !addressLocation.isEmpty else {return}
        
        
        
        let lat = coordinate?.latitude ?? devMntLat
        let long = coordinate?.longitude ?? devMntLon
        
        // NOTE: - Note sure if this logged In User is needed in this func
        //        if let loggedInUser = UserController.shared.loggedInUser {
        
        // MARK: - Update
        if let location = location {
            LocationController.shared.updateTargetLocation(location: location, geoCodeAddressString: addressLocation, addressTitle: locationTitle, latitude: lat, longitude: long) { (success) in
                if success {
                    print("🙏🏽 Success updating Location")
                    DispatchQueue.main.async {
                        // Do any UI STuff here that would be triggered by a successful update
//                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
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
            
            LocationController.shared.createNewLocation(geoCodeAddressString: addressLocation, addressTitle: locationTitle, longitude: long, latitude: lat) { (success) in
                if success {
                    // call create
                    NotificationController.createLocalNotifciation(with: locationTitle)
                    print("\n🙏🏽Successfully created/saved location🙏🏽")
                    DispatchQueue.main.async {
//                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("\n💀 Error saving Location to Cloud Kit 💀")
                    DispatchQueue.main.async {
                        self.present(self.networkErroNoif, animated: true, completion: nil)
                    }
                }
            }
        }
    }// Last curly for search button tapped
    
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
 
}
