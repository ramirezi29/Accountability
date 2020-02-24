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
import MessageUI
import AVFoundation
import ContactsUI

protocol WalkThroughContentVCDelegate: class {
    func validUserNameEntered(username: String, isHidden: Bool)
}

// TOP VC
class WalkThroughContentVC: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: -  Outlets
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var imageViewWidthToSuperView: NSLayoutConstraint!
    @IBOutlet weak var imageViewHightToSuperView: NSLayoutConstraint!
    
    @IBOutlet var headLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
            headLineLabel.textColor = ColorPallet.blackGrey.value
        }
    }
    
    @IBOutlet var subHeadLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
            headLineLabel.textColor = ColorPallet.blackGrey.value
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var upperSaveButtonView: IRButton!
    
    weak var delegate: WalkThroughContentVCDelegate?
    
    private let locationManger = CLLocationManager()
    private let center = UNUserNotificationCenter.current()
    private let londonLatitude = 51.50998
    private let londonLongitude = -0.1337
    private let desiredRadius = 60.96
    private let londonID = "devMntID"
    private let londonRequestID = "devMntRequestID"
    var index = 0
    var headLine = ""
    var subHeadLine = ""
    var imageFile = ""
    var user: User?
    var location: Location?
    var loggedInUserExist: Bool? 
    
    
    // Bools and Keys to for UIAlert
    var disableRestrictedAlertBool = false
    var disableDeniedAlertBool = false
    private var permissionInquired = false
    private let deniedBoolKey = "disabledDeniedAlertBool"
    private let restrictedBoolKey = "disabledRestrictedAlertBool"
    private let loggedInUserExistKey = "loggedInUserExist"
    //Location
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //upper save button
        upperSaveButtonView.isHidden = true
        //location
        locationManger.delegate = self
        
        let center = CLLocationCoordinate2D(latitude: londonLatitude, longitude: londonLongitude)
        
        let devMountainRegion = CLCircularRegion(center: center, radius: desiredRadius, identifier: londonID)
        
        locationManger.startMonitoring(for: devMountainRegion)
        
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManger.distanceFilter = 10
        
        //updateViews
        UserController.shared.fetchCurrentUser { (success, _) in
            if success {
                if ((UserController.shared.loggedInUser) != nil) || UserController.shared.loggedInUser?.ckRecordID != nil {
                    self.loggedInUserExist = true
                    
                    print("User was fetched successfully with CKRECORD: \(String(describing: self.user?.appleUserRef)) and \(String(describing: UserController.shared.loggedInUser?.sponsorName)) and loggedInUserExist is \(String(describing: self.loggedInUserExist))")
                }
            }else {
                print("No User CKR exists ")
                self.loggedInUserExist = false
            }
            UserDefaults.standard.set(self.loggedInUserExist, forKey: self.loggedInUserExistKey)
        }
        
        loadLoggedUserDefaults()
        
        //Tst print
        //print("\(String(describing: self.loggedInUserExist))")
        
        //Text Fields
        hideTextFields()
        
        contactButton.isHidden = true
        
        //User Name Text Field
        view.addSubview(userNameTextField)
        userNameConstraints()
        userNameTextField.delegate = self
        sponsorsNameTextField.delegate = self
        sponsorsEmailAddressTextField.delegate = self
        sponsorsPhoneNumberTextField.delegate = self
        aaStepTextField.delegate = self 
        
        //Contact Button
        view.addSubview(contactButton)
        contactButtonConstraints()
        
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
        borderView.backgroundColor = ColorPallet.offWhite.value
        
        backGroundView.backgroundColor = ColorPallet.powderBlue.value
        backGroundView.alpha = 1
        
        headLineLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 22)
        subHeadLineLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        
        headLineLabel.text = headLine
        subHeadLineLabel.text = subHeadLine
        contentImageView.image  = UIImage(named: imageFile)
        
        switch index {
            
        case 3:
            self.textFieldsDisappearAnimation()
        case 4:
            
            self.hideTextFields()
            self.contactButton.isHidden = true
            
        case 5:
            
            contentImageView.alpha = 0.4
            
            //Test Print
            //print("\(String(describing: self.loggedInUserExist)) and user defautls has it as \(UserDefaults.standard.bool(forKey: loggedInUserExistKey))")
            
            if loggedInUserExist == false || UserController.shared.loggedInUser == nil {
                self.textFieldAlphaZero()
                self.showTextFields()
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WalkThroughContentVC.hideKeyboard))
                
                tapGesture.cancelsTouchesInView = true
                
                self.view.addGestureRecognizer(tapGesture)
                
                //Edge case, in order to present the animation to the user when they naviagete to this particular index slowly
                let deadlineTime = DispatchTime.now() + .seconds(1)
                
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    
                    DispatchQueue.main.async {
                        
                        //Uncover the top save button
                        self.upperSaveButtonView.setTitle("Save", for: .normal)
                        self.upperSaveButtonView.isHidden = false
                        self.textFieldAppearAnimation()
                    }
                }
            } else {
                print("The text fields did not appear bc logged in user exists: \(String(describing: loggedInUserExist)) and or the shared user is: \(String(describing: UserController.shared.loggedInUser))")
            }
            print("☄️ Case 5")
            
        case 6:
            
            print("☄️ Case 6")
            
            self.contactButton.isHidden = true
            
            hideTextFields()
            
        case 7:
            print(index)
            
        case 8:
            //Safety net. if permisions were not asked in the previous index, as them before they exit the onboarding screen
            self.inquirePermissions()
            print(index)
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if loggedInUserExist == true {return}
        
        guard let userName = userNameTextField.text,
            let sponsorName = sponsorsNameTextField.text,
            let sponsorsEmail = sponsorsEmailAddressTextField.text,
            let sponsorsPhoneNumber = sponsorsPhoneNumberTextField.text,
            let  aaStep = aaStepTextField.text else { return }
        
        guard let destinationVC = segue.destination as? WalkThroughVC else {return}
        
        destinationVC.userName = userName
        destinationVC.sponsorName = sponsorName
        destinationVC.sponsorPhone = sponsorsPhoneNumber
        destinationVC.sponsorEmail = sponsorsEmail
        destinationVC.aaStep = Int(aaStep) ?? 0
    }
    
    func loadLoggedUserDefaults(){
        loggedInUserExist = UserDefaults.standard.bool(forKey: loggedInUserExistKey)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateViews() {
        
        if loggedInUserExist == false {
            guard let loggedInUser = UserController.shared.loggedInUser
                else { return }
            userNameTextField.text = loggedInUser.userName
            sponsorsNameTextField.text = loggedInUser.sponsorName
            sponsorsPhoneNumberTextField.text = loggedInUser.sponsorTelephoneNumber
            sponsorsEmailAddressTextField.text = loggedInUser.sponsorEmail
            aaStepTextField.text = "\(loggedInUser.aaStep)"
        }
    }
    
    func textFieldsDisappearAnimation() {
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
    
    func textFieldAppearAnimation() {
        
        //If there is already a user update the views
        // NOTE: - This feature can be updated
        self.updateViews()
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [], animations: {
            self.userNameTextField.alpha = 1
        }) { (success) in
            
            self.userNameTextField.isUserInteractionEnabled = true
            self.contactButton.isHidden = false
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.2, options: [], animations: {
            self.sponsorsNameTextField.alpha = 1
        }) { (sucess) in
            self.sponsorsNameTextField.isUserInteractionEnabled = true
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.4, options: [], animations: {
            self.sponsorsPhoneNumberTextField.alpha = 1
        }) { (success) in
            self.sponsorsPhoneNumberTextField.isUserInteractionEnabled = true
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.6, options: [], animations: {
            self.sponsorsEmailAddressTextField.alpha = 1
        }) { (success) in
            self.sponsorsEmailAddressTextField.isUserInteractionEnabled = true
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.8, options: [], animations: {
            self.aaStepTextField.alpha = 1
        }) { (success) in
            self.aaStepTextField.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Permission Func
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
                
                
                let restrictedAlertController = AlertController.presentAlertControllerWith(alertTitle: "Location Services Denied", alertMessage: "It seems your device does not support location services", dismissActionTitle: "OK")
                
                DispatchQueue.main.async {
                    self.present(restrictedAlertController, animated: true)
                }
            }
            
            print("\nUsers location is restricted")
            
        case .denied:
            if disableDeniedAlertBool == false {
                disableDeniedAlertBool = true
                
                UserDefaults.standard.set(disableDeniedAlertBool, forKey: deniedBoolKey)
                
                let deniedAlertController = AlertController.presentAlertControllerWith(alertTitle: "To beter serve you allow location services", alertMessage: "Go to your device's settings and allow location service", dismissActionTitle: "OK")
                
                DispatchQueue.main.async {
                    self.present(deniedAlertController, animated: true)
                }
            }
            print("\nUser denied access to use their location\n")
            
        case .authorizedWhenInUse:
            print("\nuser granted authorizedWhenInUse\n")
            
        case .authorizedAlways:
            print("\nuser selected authorizedAlways\n")
            
        default: break
        }
    }
    
    // Contact Button
    lazy var contactButton: UIButton = {
        let contactButtonImage = UIImage(named: "phoneBook")
        let button = UIButton()
        button.setImage(contactButtonImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(contactButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    //Programatic Text Fields
    //User Name
    lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        textField.backgroundColor = ColorPallet.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Your Name", attributes: [NSAttributedString.Key.foregroundColor: ColorPallet.blackGrey.value])
        
        return textField
    }()
    
    //SponsorName
    lazy var sponsorsNameTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        textField.backgroundColor = ColorPallet.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Name", attributes: [NSAttributedString.Key.foregroundColor: ColorPallet.blackGrey.value])
        
        return textField
    }()
    
    lazy var sponsorsPhoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        textField.backgroundColor = ColorPallet.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Phone Number", attributes: [NSAttributedString.Key.foregroundColor: ColorPallet.blackGrey.value])
        
        return textField
    }()
    
    lazy var sponsorsEmailAddressTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        textField.backgroundColor = ColorPallet.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Email Address", attributes: [NSAttributedString.Key.foregroundColor: ColorPallet.blackGrey.value])
        
        return textField
    }()
    
    lazy var aaStepTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 7
        
        textField.backgroundColor = ColorPallet.offWhite.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "If in AA, enter current step", attributes: [NSAttributedString.Key.foregroundColor: ColorPallet.blackGrey.value])
        
        return textField
    }()
    
    // Contact Button Constraints
    func contactButtonConstraints() {
        contactButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contactButton.leadingAnchor.constraint(equalTo: headLineLabel.trailingAnchor, constant: -60),
            contactButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 0),
            contactButton.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 35),
            
        ])
    }
    
    //User Name Constraints
    func userNameConstraints() {
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userNameTextField.topAnchor.constraint(equalTo: headLineLabel.bottomAnchor, constant: 15),
            userNameTextField.leadingAnchor.constraint(equalTo: contentImageView.leadingAnchor, constant: 0)
        ])
    }
    
    //Sponsors Name Constraint
    func sponsorsNameContraints() {
        
        sponsorsNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sponsorsNameTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 15),
            sponsorsNameTextField.leadingAnchor.constraint(equalTo: userNameTextField.leadingAnchor, constant: 0)
        ])
    }
    
    //Sponsor Telephone Constraints
    func sponorsPhoneNumberConstraints() {
        sponsorsPhoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sponsorsPhoneNumberTextField.topAnchor.constraint(equalTo: sponsorsNameTextField.bottomAnchor, constant: 15),
            sponsorsPhoneNumberTextField.leadingAnchor.constraint(equalTo: sponsorsNameTextField.leadingAnchor, constant: 0)
        ])
    }
    
    func sponorsEmailConstraints() {
        sponsorsEmailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sponsorsEmailAddressTextField.topAnchor.constraint(equalTo: sponsorsPhoneNumberTextField.bottomAnchor, constant: 15),
            sponsorsEmailAddressTextField.leadingAnchor.constraint(equalTo: sponsorsPhoneNumberTextField.leadingAnchor, constant: 0)
        ])
    }
    
    func aaStepConstraint() {
        aaStepTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            aaStepTextField.topAnchor.constraint(equalTo: sponsorsEmailAddressTextField.bottomAnchor, constant: 15),
            aaStepTextField.leadingAnchor.constraint(equalTo: sponsorsEmailAddressTextField.leadingAnchor, constant: 0)
        ])
    }
    
    //Actions
    @IBAction func upperSaveButtonTapped(_ sender: IRButton) {
        
        self.saveInfoToCloudKit { (success) in
            if success {
                UIView.animateKeyframes(withDuration: 2, delay: 0, options: [], animations: {
                    DispatchQueue.main.async {
                        self.upperSaveButtonView.frame.origin.y += 200
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 1.3, animations: {
                        DispatchQueue.main.async {
                            self.textFieldAlphaZero()
                            self.contactButton.alpha = 0
                        }
                    })
                }, completion: nil)
            }
        }
    }
}

//Location Delegates For Test Purposes Uncommented the code to view print statments
extension WalkThroughContentVC {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        //NOTE: - Uncomment in order for testing purposes
        //print("🌎 didEnterRegion: User Entered location🌎")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        //print("🌎 didStartMonitoringFor: The monitored regions are: \(manager.monitoredRegions)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //NOTE: - Uncomment in order for testing purposes
        //        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        //uncomment in order for testing purposes
        //        print("🌎 didUpdateLocations: locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

extension WalkThroughContentVC : UITextFieldDelegate {
    
    // MARK: - Future version check to make sure their is valid info in the textfields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //        if textField.text!.count + 1 >= 2 {
        //            delegate?.validUserNameEntered(username: string, isHidden: false)
        //            return true
        //        }
        //
        //        if textField.text!.count - 1 < 2 {
        //            delegate?.validUserNameEntered(username: "", isHidden: true)
        //        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameTextField:
            userNameTextField.returnKeyType = .next
        case sponsorsNameTextField:
            sponsorsNameTextField.returnKeyType = .next
        case sponsorsPhoneNumberTextField:
            sponsorsPhoneNumberTextField.keyboardType = .phonePad
            sponsorsPhoneNumberTextField.returnKeyType = .next
        case sponsorsEmailAddressTextField:
            sponsorsEmailAddressTextField.keyboardType = .emailAddress
            sponsorsEmailAddressTextField.returnKeyType = .next
        case aaStepTextField:
            aaStepTextField.keyboardType = .numberPad
            
        default: break
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case userNameTextField:
            sponsorsNameTextField.becomeFirstResponder()
        case sponsorsNameTextField:
            sponsorsPhoneNumberTextField.becomeFirstResponder()
        case sponsorsPhoneNumberTextField:
            sponsorsEmailAddressTextField.becomeFirstResponder()
        case sponsorsEmailAddressTextField:
            aaStepTextField.becomeFirstResponder()
        default:
            aaStepTextField.resignFirstResponder()
        }
        return false
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

// MARK: - Contact Button Action
extension WalkThroughContentVC: CNContactPickerDelegate {
    
    @objc private func contactButtonAction(_ sender: UIButton?) {
        loadLoggedUserDefaults()
        
        let picker = CNContactPickerViewController()
        picker.delegate = self
        picker.predicateForEnablingContact = NSPredicate(format: "emailAddresses.@count > 0")
        picker.predicateForSelectionOfContact = NSPredicate(format: "emailAddresses.@count == 1")
        present(picker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        for data in contact.phoneNumbers {
            let contactInfo = data.value
            sponsorsPhoneNumberTextField.text = contactInfo.stringValue
        }
        
        let sponsorsName = contact.givenName
        let sponsorsFamilyName = contact.familyName
        let email = contact.emailAddresses.first
        let emailString = email?.value
        
        sponsorsNameTextField.text = "\(sponsorsName) \(sponsorsFamilyName)"
        sponsorsEmailAddressTextField.text = "\(emailString ?? "")"
    }
}

extension WalkThroughContentVC {
    func saveInfoToCloudKit(completion: @escaping (Bool) -> Void) {
        if loggedInUserExist == true {return}
        guard let userName = userNameTextField.text,
            let sponsorName = sponsorsNameTextField.text,
            let sponsorsEmail = sponsorsEmailAddressTextField.text,
            let sponsorsPhoneNumber = sponsorsPhoneNumberTextField.text,
            let  aaStep = aaStepTextField.text else { return }
        
        UserController.shared.createNewUserDetailsWith(userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorsPhoneNumber, sponsorEmail: sponsorsEmail, aaStep: Int(aaStep) ?? 0) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.title = "Sucessflly Saved Example saveInfoToCloudKit func"
                }
                completion(true)
            } else {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                let errorMessage = AlertController.presentAlertControllerWith(alertTitle: "Error Saving Information", alertMessage: "Ensure that you are connected to the internet and are signed into your iCloud account", dismissActionTitle: "OK")
                DispatchQueue.main.async {
                    self.present(errorMessage, animated: true, completion: nil)
                }
                // prseent UI Alert expalining error
                completion(false)
                return
            }
        }
    }
}

