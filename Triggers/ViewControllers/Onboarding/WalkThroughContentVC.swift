//
//  WalkThroughVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

protocol WalkThroughContentVCDelegate: class {
    func validUserNameEntered(username: String, isHidden: Bool)
}

class WalkThroughContentVC: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate     {
    
    @IBOutlet var viewOutlet: UIView!
    
    @IBOutlet var headLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subHeadLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    weak var delegate: WalkThroughContentVCDelegate?
    private let locationManger = CLLocationManager()
    var index = 0
    var headLine = ""
    var subHeadLine = ""
    var imageFile = ""
    
    // Bools and Keys to for UIAlert
    var disableRestrictedAlertBool = false
    var disableDeniedAlertBool = false
    private let deniedBoolKey = "disabledDeniedAlertBool"
    private let restrictedBoolKey = "disabledRestrictedAlertBool"
    
    lazy var sponseeNameTextField: UITextField = {
        
        let textField = UITextField()
        
        //        textField.addTarget(self, action: #selector(firePermissionRequests(_:)), for: .touchDragInside)
        textField.backgroundColor = UIColor.blue
        textField.placeholder = "Enter Name"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sponseeNameTextField.delegate = self
        sponseeNameTextField.resignFirstResponder()
        //userDefaults
        loadUserDefaults()
    
        //laction Request Button
        sponseeNameTextField.isHidden = true
        
        
        view.addSubview(sponseeNameTextField)
        requestButtonConstraints()
        
        // Location Delegate
        locationManger.delegate = self
        //viewbackground
        viewOutlet.backgroundColor = .black
        
        //Text Color
        headLineLabel.textColor = .white
        subHeadLineLabel.textColor = .white 
        
        headLineLabel.text = headLine
        subHeadLineLabel.text = subHeadLine
        contentImageView.image  = UIImage(named: imageFile)
        
        if index == 5 {
            inquirePermissions()
            
            sponseeNameTextField.isUserInteractionEnabled = false
            sponseeNameTextField.isHidden = true
            UIView.animateKeyframes(withDuration: 0.4, delay: 0.1, options: [], animations: {
                self.sponseeNameTextField.alpha = 0.0
            }) { (success) in
                self.sponseeNameTextField.isHidden = true
                print("\nsponseeNameTextField in index 6 completed\n")
            }
        }
        
        //        if index == 4 {
        //            //            sponseeNameTextField.alpha = 0.0
        //            sponseeNameTextField.isUserInteractionEnabled = false
        //            sponseeNameTextField.isHidden = true
        //            UIView.animateKeyframes(withDuration: 0.4, delay: 0.1, options: [], animations: {
        //                self.sponseeNameTextField.alpha = 0.0
        //            }) { (success) in
        //                self.sponseeNameTextField.isHidden = true
        //                print("\nsponseeNameTextField in index 6 completed\n")
        //            }
        //        }
        
        if index == 6 {
            sponseeNameTextField.alpha = 0.0
            sponseeNameTextField.isHidden = false
            
            UIView.animateKeyframes(withDuration: 10.0, delay: 0.1, options: [], animations: {
                self.sponseeNameTextField.alpha = 1.0
            }) { (success) in
                self.sponseeNameTextField.isUserInteractionEnabled = true
                print("\nsponseeNameTextField in index 6 completed\n")
            }
            
        }
        
    }
    
    
    func inquirePermissions() {
        
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
            self.locationManger.startUpdatingLocation()
        }
    }
    
    
    @objc private func firePermissionRequests(_ sender: UIButton?) {
        //        requestLocation()
        //        requestNotificationPermission()
        
        
    }
    
    
    func loadUserDefaults() {
        disableDeniedAlertBool = UserDefaults.standard.bool(forKey: deniedBoolKey)
        disableRestrictedAlertBool = UserDefaults.standard.bool(forKey: restrictedBoolKey)
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
                    //                    self.presentMainView()
                }
                
                [dismissAction].forEach { restrictedAlertController.addAction($0)}
                
                present(restrictedAlertController, animated: true)
            }
            //            else {
            //                presentMainView()
            //            }
            print("\nUsers location is restricted")
            
        case .denied:
            
            if disableDeniedAlertBool == false {
                disableDeniedAlertBool = true
                
                UserDefaults.standard.set(disableDeniedAlertBool, forKey: deniedBoolKey)
                
                let deniedAlertController = UIAlertController(title: NSString.localizedUserNotificationString(forKey: "locationServiceDeniedAlertTitle", arguments: []), message: NSString.localizedUserNotificationString(forKey: "locationServiceDeniedAlertMessage", arguments: []), preferredStyle: .alert)
                
                //                    UIAlertController(title: NSLocalizedString("locationServiceDeniedAlertTitle", comment: ""), message: NSLocalizedString("locationServiceDeniedAlertMessage", comment: ""), preferredStyle: .alert)
                
                let dismissAction = UIAlertAction(title: NSString.localizedUserNotificationString(forKey: "dismissLocationActionTitle", arguments: []), style: .cancel) { (alert) in
                    //                    self.presentMainView()
                }
                
                [dismissAction].forEach { deniedAlertController.addAction($0)}
                
                present(deniedAlertController, animated: true)
            }
            //            else {
            //                presentMainView()
            //            }
            print("\nUser denied access to use their location\n")
            
        case .authorizedWhenInUse:
            print("\nuser granted authorizedWhenInUse\n")
            //            presentMainView()
            
        case .authorizedAlways:
            print("\nuser selected authorizedAlways\n")
        //            presentMainView()
        default: break
        }
    }
    
    func requestButtonConstraints() {
        sponseeNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        sponseeNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        
        sponseeNameTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1).isActive = true
        sponseeNameTextField.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 0.8)
        sponseeNameTextField.layer.cornerRadius = 9
    }
    
    // MARK: - Segue the onboarding textfilds to the Home VC
// This doesnt get hit 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sponseeName = sponseeNameTextField.text else {return}
        
        guard let destinationVC = segue.destination as? HomeViewController else {return}
        destinationVC.sponsorNameTextField.text = sponseeName
    }
}

extension WalkThroughContentVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.count + 1 >= 2 {
            delegate?.validUserNameEntered(username: string, isHidden: false)
            return true
        }
        
        if textField.text!.count - 1 < 2 {
            delegate?.validUserNameEntered(username: "", isHidden: true)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sponseeNameTextField.resignFirstResponder()
//        textField = sponseeNameTextField.resignFirstResponder()
        return true
    }
}
