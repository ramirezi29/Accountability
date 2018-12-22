//
//  LocationViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import MapKit



class LocationDetailVC: UIViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var enterAddressLabel: UILabel!
    @IBOutlet weak var enterTitleLabel: UILabel!
    @IBOutlet weak var locationTitleTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    
    //Mark: - Landing Pad
    var location: Location?
    
    private let geocoder = CLGeocoder()
    
    private let metersPerMile = 1609.344
    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    private let devMntLat = 40.761806
    private let devMntLon = -111.890534
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
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
        
        guard let location = location else {
            print("\n guard let location = location else\n")
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
        
        
    }
}
