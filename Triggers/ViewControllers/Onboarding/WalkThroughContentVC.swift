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
    
    // MARK: -  Outlets
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    
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
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Text Fields
        hideTextFields()
        
        //User Name Text Field
        
        view.addSubview(userNameTextField)
        userNameConstraints()
        userNameTextField.delegate = self
        userNameTextField.resignFirstResponder()
        
        
        //Sponsors Name Text Field
        view.addSubview(sponsorsNameTextField)
        sponsorsNameContraints()
        
        
        //Sponosrs Phone Number
        view.addSubview(sponsorsPhoneNumberTextField)
        sponorsPhoneNumberConstraints()
        
        //Sponosrs Email Address
        view.addSubview(sponsorsEmailAddressTextField)
        sponorsEmailConstraints()
        
        
        //Current AA Step
        view.addSubview(aaStepTextField)
        aaStepConstraint()

        //userDefaults
        loadUserDefaults()
        
        // Location Delegate
        locationManger.delegate = self
        
        //viewbackground
        borderView.backgroundColor = MyColor.offWhite.value
        
        backGroundView.backgroundColor = MyColor.powderBlue.value
        backGroundView.alpha = 1
        
        //Text Color
        headLineLabel.textColor = MyColor.offGrey.value
        subHeadLineLabel.textColor = MyColor.offGrey.value
        
//        nameLabel.textColor = UIColor(displayP3Red: 55/255, green: 215/255, blue: 239/255, alpha: 1.0)
        headLineLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 22)
         subHeadLineLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        
        headLineLabel.text = headLine
        subHeadLineLabel.text = subHeadLine
        contentImageView.image  = UIImage(named: imageFile)
        
        if index == 5 {
            
            // UNNotifcation and Location Permission
            inquirePermissions()
            
            
            //Text Fields
            inactivateTextFields()
            
            // MARK: - Text Fields Fade Out Animation
            UIView.animateKeyframes(withDuration: 0.9, delay: 0.1, options: [], animations: {
                self.userNameTextField.alpha = 0.0
            }) { (success) in
                self.userNameTextField.isHidden = true
                print("\nUser Text Fiela: Alpha 0\n")
            }
            
            UIView.animate(withDuration: 0.9, delay: 0.2, options: [], animations: {
                self.sponsorsNameTextField.alpha = 0.0
            }) { (success) in
                self.sponsorsNameTextField.isHidden = true
            }
            
            UIView.animate(withDuration: 0.9, delay: 0.2, options: [], animations: {
                self.sponsorsPhoneNumberTextField.alpha = 0.0
            }) { (success) in
                self.sponsorsPhoneNumberTextField.isHidden = true
            }
            
            UIView.animate(withDuration: 0.9, delay: 0.2, options: [], animations: {
                self.sponsorsEmailAddressTextField.alpha = 0.0
            }) { (success) in
                self.sponsorsEmailAddressTextField.isHidden = true
            }
            
            UIView.animate(withDuration: 0.9, delay: 0.2, options: [], animations: {
                self.aaStepTextField.alpha = 0.0
            }) { (success) in
                self.aaStepTextField.isHidden = true
            }
            
        }
        
        // MARK: - Index if Statments
        if index == 6 {
            
            UIView.animate(withDuration: 2.0, delay: 0.2, usingSpringWithDamping: 2.0, initialSpringVelocity: 1.0, options: [.curveEaseIn], animations: {
                self.contentImageView.center.x -= self.view.bounds.width
            }) { (success) in
                if success {
                    print("🐶Animation for Image completed")
                }
            }
            
            textFieldAlphaZero()
            showTextFields()
            // MARK: - Text Fields Appear Animation
            UIView.animateKeyframes(withDuration: 5.0, delay: 0.1, options: [], animations: {
                self.userNameTextField.alpha = 1.0
            }) { (success) in
                self.userNameTextField.isUserInteractionEnabled = true
                print("\ns🚢 User NameTextField was successfuly shown to the User in index 6 \n")
            }
            
            UIView.animateKeyframes(withDuration: 5.0, delay: 0.2, options: [], animations: {
                self.sponsorsNameTextField.alpha = 1.0
            }) { (sucess) in
                self.sponsorsNameTextField.isUserInteractionEnabled = true
                print("\ns🚢 Sponsor Name Text Field was successfuly shown to the User in index 6 \n")
            }
            
            UIView.animateKeyframes(withDuration: 5.0, delay: 0.3, options: [], animations: {
                self.sponsorsPhoneNumberTextField.alpha = 1.0
            }) { (success) in
                self.sponsorsPhoneNumberTextField.isUserInteractionEnabled = true
                print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
            }
            
            UIView.animateKeyframes(withDuration: 5.0, delay: 0.4, options: [], animations: {
                self.sponsorsEmailAddressTextField.alpha = 1.0
            }) { (success) in
                self.sponsorsEmailAddressTextField.isUserInteractionEnabled = true
                print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
            }
            
            UIView.animateKeyframes(withDuration: 5.0, delay: 0.5, options: [], animations: {
                self.aaStepTextField.alpha = 1.0
            }) { (success) in
                self.aaStepTextField.isUserInteractionEnabled = true
                print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
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
    
    //Programatic Text Fields
    //User Name
    lazy var userNameTextField: UITextField = {
        
        let textField = UITextField()
        
        textField.backgroundColor = MyColor.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return textField
    }()
    
    //SponsorName
    lazy var sponsorsNameTextField: UITextField = {
        
        let textField = UITextField()
        
        textField.backgroundColor = MyColor.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return textField
    }()
    
    lazy var sponsorsPhoneNumberTextField: UITextField = {
        
        let textField = UITextField()
        
        textField.backgroundColor = MyColor.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return textField
    }()
    
    lazy var sponsorsEmailAddressTextField: UITextField = {
        
        let textField = UITextField()
        
        textField.backgroundColor = MyColor.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return textField
    }()
    
    lazy var aaStepTextField: UITextField = {
        
        let textField = UITextField()
        
        textField.backgroundColor = MyColor.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "If in treatment enter current Step", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        return textField
    }()
    
    //User Name Constraints
    func userNameConstraints() {
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        userNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        userNameTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1).isActive = true
        
        userNameTextField.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 0.8)
        
        userNameTextField.layer.cornerRadius = 9
    }
    
    //Sponsors Name Constraint
    func sponsorsNameContraints() {
        sponsorsNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        
        sponsorsNameTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.8).isActive = true
        
        sponsorsNameTextField.layer.cornerRadius = 9
    }
    
    //Sponsor Telephone Constraints
    func sponorsPhoneNumberConstraints() {
        sponsorsPhoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsPhoneNumberTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
        sponsorsPhoneNumberTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.8).isActive = true
        
        sponsorsPhoneNumberTextField.layer.cornerRadius = 9
    }
    
    func sponorsEmailConstraints() {
        sponsorsEmailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsEmailAddressTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        
        sponsorsEmailAddressTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.8).isActive = true
        
        sponsorsEmailAddressTextField.layer.cornerRadius = 9
    }
    
    func aaStepConstraint() {
        aaStepTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        aaStepTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        
        aaStepTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.8).isActive = true
        
        aaStepTextField.layer.cornerRadius = 9
    }
    
    
    // MARK: - Segue the onboarding textfilds to the Home VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let usersName = userNameTextField.text, !usersName.isEmpty,
            let sponsorsName = sponsorsNameTextField.text,
            let sponsorsEmail = sponsorsEmailAddressTextField.text,
            let sponsorsPhoneNumber = sponsorsPhoneNumberTextField.text,
            let aaStep = aaStepTextField.text
            else {return}
        
        guard let destinationVC = segue.destination as? HomeVC else {return}
        destinationVC.userNameTextField.text = usersName
        destinationVC.sponsorsNameTextField.text = sponsorsName
        destinationVC.sponsorsEmailTextField.text = sponsorsEmail
        destinationVC.sponsorsPhoneNumberTextField.text = sponsorsPhoneNumber
        destinationVC.currentAaStepLabel.text = aaStep
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
        userNameTextField.resignFirstResponder()
        return true
    }
}

extension WalkThroughContentVC {
    
    func hideTextFields() {
        userNameTextField.isHidden = true
        sponsorsNameTextField.isHidden = true
        sponsorsPhoneNumberTextField.isHidden = true
        sponsorsEmailAddressTextField.isHidden = true
        aaStepTextField.isHidden = true
    }
    
    func inactivateTextFields() {
        userNameTextField.isUserInteractionEnabled = false
        sponsorsNameTextField.isUserInteractionEnabled = false
        sponsorsEmailAddressTextField.isUserInteractionEnabled = false
        sponsorsPhoneNumberTextField.isUserInteractionEnabled = false
        aaStepTextField.isUserInteractionEnabled = false
    }
    
    // Testing purposes
    func showTextFields() {
        userNameTextField.isHidden = false
        sponsorsNameTextField.isHidden = false
        sponsorsPhoneNumberTextField.isHidden = false
        sponsorsEmailAddressTextField.isHidden = false
        aaStepTextField.isHidden = false
    }
    
    func textFieldAlphaZero(){
        userNameTextField.alpha = 0.0
        sponsorsNameTextField.alpha = 0.0
        sponsorsEmailAddressTextField.alpha = 0.0
        sponsorsPhoneNumberTextField.alpha = 0.0
        aaStepTextField.alpha = 0.0
    }
    
    func textFieldAlphaOne(){
        userNameTextField.alpha = 1.0
        sponsorsNameTextField.alpha = 1.0
        sponsorsEmailAddressTextField.alpha = 1.0
        sponsorsPhoneNumberTextField.alpha = 1.0
        aaStepTextField.alpha = 1.0
    }
}
