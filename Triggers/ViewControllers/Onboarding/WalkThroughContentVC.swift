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
    
    @IBOutlet var headLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
            headLineLabel.textColor = MyColor.blackGrey.value
        }
    }
    
    @IBOutlet var subHeadLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
            headLineLabel.textColor = MyColor.blackGrey.value
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    weak var delegate: WalkThroughContentVCDelegate?
    
    private let locationManger = CLLocationManager()
    private let center = UNUserNotificationCenter.current()
    private let devMountainLatitude = 40.761806
    private let devMountainLongitude = -111.890533
    private let desiredRadius = 60.96
    private let devMntID = "devMntID"
    private let devMntRequestID = "devMntRequestID"
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
    private let deniedBoolKey = "disabledDeniedAlertBool"
    private let restrictedBoolKey = "disabledRestrictedAlertBool"
    private let loggedInUserExistKey = "loggedInUserExist"
    //Location
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Delegates
        
        //Save realted delegate
        
        
        //location
        locationManger.delegate = self
        
        let center = CLLocationCoordinate2D(latitude: devMountainLatitude, longitude: devMountainLongitude)
        
        let utahHousingActualregion = CLCircularRegion(center: center, radius: desiredRadius, identifier: devMntID)
        
        locationManger.startMonitoring(for: utahHousingActualregion)
        
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
        print("\(String(describing: self.loggedInUserExist))")
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
        borderView.backgroundColor = MyColor.offWhite.value
        
        backGroundView.backgroundColor = MyColor.powderBlue.value
        backGroundView.alpha = 1
        
        headLineLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 22)
        subHeadLineLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        
        headLineLabel.text = headLine
        subHeadLineLabel.text = subHeadLine
        contentImageView.image  = UIImage(named: imageFile)
        
        switch index {
            
        case 2:
            self.textFieldsDisappearAnimation()
        case 3:
            print("\n🔷 DOnt feel isolated view🌎\n")
            
            self.hideTextFields()
            self.contactButton.isHidden = true
            
            
            //            //Fetch the user
            //            UserController.shared.fetchCurrentUser { (success, error) in
            //                if success {
            //                    DispatchQueue.main.async {
            //                        // UI Stuff
            //                    }
            //
            //                } else {
            //
            //                    DispatchQueue.main.async {
            //                        //UI Stuff
            //                    }
            //                    print("\n🤯 Error fechign current user Data \n")
            //                    return
            //                }
        //            }
        case 4:
            
            //Test print
            loadLoggedUserDefaults()
            
            print("\(String(describing: self.loggedInUserExist)) and user defautls has it as \(UserDefaults.standard.bool(forKey: loggedInUserExistKey))")
            
            if loggedInUserExist == false {
                self.textFieldAlphaZero()
                self.showTextFields()
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WalkThroughContentVC.hideKeyboard))
                
                tapGesture.cancelsTouchesInView = true
                self.view.addGestureRecognizer(tapGesture)
                
                let deadlineTime = DispatchTime.now() + .seconds(1)
                
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    print("test")
                    DispatchQueue.main.async {
                        print("🎸🎸🎸🎸🎸TExt Fields should appear now")
                        self.textFieldAppearAnimation()
                    }
                }
            }
            
        case 5:
            
            self.contactButton.isHidden = true
            hideTextFields()
            
        case 6:
            
            self.inquirePermissions()
            
        default:
            break
        }
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
        print("🍁🍁🍁🍁🍁text field appear animation was called )")
        self.updateViews()
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [], animations: {
            self.userNameTextField.alpha = 0.5
        }) { (success) in
            
            self.userNameTextField.isUserInteractionEnabled = true
            self.contactButton.isHidden = false
            print("\n ☎️ contact button appeared\n")
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.2, options: [], animations: {
            self.sponsorsNameTextField.alpha = 0.5
        }) { (sucess) in
            self.sponsorsNameTextField.isUserInteractionEnabled = true
            //            print("\ns🚢 Sponsor Name Text Field was successfuly shown to the User in index 6 \n")
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.4, options: [], animations: {
            self.sponsorsPhoneNumberTextField.alpha = 0.5
        }) { (success) in
            self.sponsorsPhoneNumberTextField.isUserInteractionEnabled = true
            //            print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.6, options: [], animations: {
            self.sponsorsEmailAddressTextField.alpha = 0.5
        }) { (success) in
            self.sponsorsEmailAddressTextField.isUserInteractionEnabled = true
            //            print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
        }
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.8, options: [], animations: {
            self.aaStepTextField.alpha = 0.5
        }) { (success) in
            self.aaStepTextField.isUserInteractionEnabled = true
            //            print("\ns🚢 Sponsor NameTextField was successfuly shown to the User in index 6 \n")
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
        //Test Purposes
        //        textField.text = "Jan 07 User Name Exaample"
        
        textField.backgroundColor = MyColor.offWhiteLowAlpha.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Name", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        return textField
    }()
    
    //SponsorName
    lazy var sponsorsNameTextField: UITextField = {
        
        let textField = UITextField()
        //Test Purposes
        //textField.text = "🐠🐠🐠🐠"
        
        textField.backgroundColor = MyColor.offWhiteLowAlpha.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Name", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        return textField
    }()
    
    lazy var sponsorsPhoneNumberTextField: UITextField = {
        
        let textField = UITextField()
        //Test Purposes
        //textField.text = "☔️☔️☔️☔️"
        
        textField.backgroundColor = MyColor.offWhiteLowAlpha.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Phone Number", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        return textField
    }()
    
    lazy var sponsorsEmailAddressTextField: UITextField = {
        
        let textField = UITextField()
        
        //Test Purposes
        //textField.text = "🍎🍎🍎🍎"
        
        textField.backgroundColor = MyColor.offWhiteLowAlpha.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Sponsor's Email Address", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        return textField
    }()
    
    lazy var aaStepTextField: UITextField = {
        
        let textField = UITextField()
        //Test Purposes
        //textField.text = "12"
        textField.backgroundColor = MyColor.offWhiteLowAlpha.value
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: "If in treatment enter current Step", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        return textField
    }()
    
    // Contact Button Constraints
    func contactButtonConstraints() {
        contactButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contactButton.leadingAnchor.constraint(equalTo: headLineLabel.trailingAnchor, constant: -60),
            
            contactButton.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 0),
            //
            contactButton.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 35),
            //
            //            contactButton.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 0)
            
            ])
    }
    
    //User Name Constraints
    func userNameConstraints() {
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        userNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        
        userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100).isActive = true
        
        userNameTextField.layer.cornerRadius = 9
    }
    
    //Sponsors Name Constraint
    func sponsorsNameContraints() {
        sponsorsNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
        
        sponsorsNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        
        sponsorsNameTextField.layer.cornerRadius = 9
    }
    
    //Sponsor Telephone Constraints
    func sponorsPhoneNumberConstraints() {
        sponsorsPhoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsPhoneNumberTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        
        sponsorsPhoneNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        
        sponsorsPhoneNumberTextField.layer.cornerRadius = 9
    }
    
    func sponorsEmailConstraints() {
        sponsorsEmailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        sponsorsEmailAddressTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        
        sponsorsEmailAddressTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        
        sponsorsEmailAddressTextField.layer.cornerRadius = 9
    }
    
    func aaStepConstraint() {
        aaStepTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        aaStepTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        
        aaStepTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        
        aaStepTextField.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 1).isActive = true
        
        
        aaStepTextField.layer.cornerRadius = 9
    }
    
}

extension WalkThroughContentVC {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //NOTE: - Uncomment in order for testing purposes
        //print("🚀🚀🌎 didEnterRegion: User Entered location🌎🚀🚀")
        
        
        
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

extension WalkThroughContentVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.count + 1 >= 2 {
            delegate?.validUserNameEntered(username: string, isHidden: false)
            //Note sure if this is needed, test
            return true
        }
        
        if textField.text!.count - 1 < 2 {
            delegate?.validUserNameEntered(username: "", isHidden: true)
        }
        
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
            sponsorsEmailAddressTextField.returnKeyType = .done
            
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
        print("Contact Button Tapped")
        
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
        
        
        sponsorsNameTextField.text = "\(sponsorsName) \(sponsorsFamilyName)"
        
        
        let email = contact.emailAddresses.first
        
        let emailString = email?.value
        
        sponsorsEmailAddressTextField.text = "\(emailString ?? "")"
    }
}

/*
 if let imageData = contact.imageData {
 let image = UIImage(data: imageData)
 
 print("image: \(image)")
 }
 */

extension WalkThroughContentVC {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        /*Test print*/
        print("\nNotification item response tap: \(response.notification.request.identifier)")
        
        let sponsorName = user?.sponsorName ?? "Support Person"
        let sponsorPhoneNumber = user?.sponsorTelephoneNumber ?? "18006624357"
        let sponosrEmail = user?.sponsorEmail ?? ""
        let sponsorText = user?.sponsorTelephoneNumber ?? "“741741" //include “Listen” in text message
        
        defer {
            completionHandler()
        }
        //https://www.justthinktwice.gov/facts/what-addiction
        switch response.actionIdentifier {
            //The action that indicates the user explicitly dismissed the notification interface.
        //This action is delivered only if the notification’s category object was configured with the customDismissAction option.
        case UNNotificationDismissActionIdentifier:
            print(" 'X' was tapped")
            // Do something in order to record that the geo fence was crossed but the notification was dismissed
            
        //An action that indicates the user opened the app from the notification interface.
        case UNNotificationDefaultActionIdentifier:
            print("use")
            
        case LocationConstants.telephoneSponsorActionKey:
            
            print("call the sponsor: \(sponsorName), \(sponsorPhoneNumber) ")
            
        case LocationConstants.emailSponsorActionKey:
            print("email \(sponosrEmail)")
            showMailComposer()
            
        case LocationConstants.textMessageSponsorActionKey:
            print("Text: \(sponsorName), \(sponsorText)")
            
            
        default:
            break
        }
        
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
                print("\n🙏🏽 Creating new userDetails to CK successful\n")
                DispatchQueue.main.async {
                    self.title = "Sucessflly Saved Example saveInfoToCloudKit func"
                }
                completion(true)
            } else {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                // prseent UI Alert expalining error
                print("💀error with the upating the data")
                completion(false)
                return
            }
        }
    }
}

extension WalkThroughContentVC: MFMailComposeViewControllerDelegate {
    
    
    func showMailComposer() {
        let loggedInUser = UserController.shared.loggedInUser
        
        let locationName = location?.locationTitle ?? "a place I shouldn't be at."
        let sponsorName = loggedInUser?.sponsorName ?? "Friend"
        
        //check if device can send mail
        guard MFMailComposeViewController.canSendMail() else {
            
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing E-Mail", alertMessage: "Your device does not support this feature", dismissActionTitle: "OK")
            present(notMailCompatable, animated: true, completion: nil)
            return
        }
        
        let composer = MFMailComposeViewController()
        //        composer.mailComposeDelegate = self
        //        composer.setToRecipients([sponosrEmail])
        composer.setSubject("Contact me when you get this message")
        composer.setMessageBody("\(sponsorName), I wanted to let you know that I got close to \(locationName) \n\n Contact me when you get this right away", isHTML: false)
        
        present(composer, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            controller.dismiss(animated: true, completion: nil)
            return
        }
        
        switch result {
        case .cancelled:
            print("🐦🐦🐦Cancled email")
        case .failed:
            print("🐦🐦🐦faled")
        case .saved:
            print("🐦🐦🐦mail savied")
        case .sent:
            print("🐦🐦🐦mail saved")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

