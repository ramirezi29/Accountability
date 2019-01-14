//
//  HomeViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import AVFoundation
import ContactsUI

class HomeVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var currentAAStepValueLabel: UILabel!
    @IBOutlet weak var aaPickerView: UIPickerView!
    @IBOutlet weak var phoneBookButton: UIButton!
    
    //Images
    @IBOutlet weak var aaStepImageView: UIImageView!
    @IBOutlet weak var supportPersonImageView: UIImageView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    
    //View
    @IBOutlet weak var buttomView: UIView!
    
    //Navigation Bar BUttons
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //TextFields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var sponsorsNameTextField: UITextField!
    @IBOutlet weak var sponsorsPhoneNumberTextField: UITextField!
    @IBOutlet weak var sponsorsEmailTextField: UITextField!
    
    //Activity Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorView: UIView!
    
    var editBool = false
    var isContactBookVisable = false
    let phoneBookImage = UIImage(named: "phoneBook")
    let locationLogoImage = UIImage(named: "LocationLogo")
    
    let networkErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Unable able to Save Entry", alertMessage: "The Internet connection appears to be offline", dismissActionTitle: "OK")
    let fetchErrorNotif  = AlertController.presentAlertControllerWith(alertTitle: "Unable to load data", alertMessage: "The Internet connection appears to be offline", dismissActionTitle: "OK")
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.phoneBookButton.isUserInteractionEnabled = false
        self.phoneBookButton.alpha = 0
//        self.phoneBookButton.contentMode.
        
        //activity indicator
        self.activityIndicatorView.backgroundColor = .clear
        self.activityIndicator.startAnimating()
        
        //Bar Button
        self.cancelButton.isEnabled = false
        self.cancelButton.tintColor = .clear
        
        //Update AA Labels
        updateCurrentAAStep()
        
        //Images
        supportPersonImageView.image = UIImage(named: "friendshipMaleIcon")
        phoneImageView.image = UIImage(named: "smartphone")
        emailImageView.image = UIImage(named: "paperPlaneIcon")
        aaStepImageView.image = UIImage(named: "stepIcon")
        
        //Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeVC.hideKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        self.view.addGestureRecognizer(tapGesture)
        
        // Text Field
        self.userNameTextField.delegate = self
        self.sponsorsNameTextField.delegate = self
        self.sponsorsPhoneNumberTextField.delegate = self
        self.sponsorsEmailTextField.delegate = self
        
        //Text fields and Keyboard
        self.userNameTextField.returnKeyType = .next
        self.sponsorsNameTextField.returnKeyType = .next
        self.sponsorsPhoneNumberTextField.returnKeyType = .next
        self.sponsorsEmailTextField.returnKeyType = .done
        
        self.userNameTextField.layer.cornerRadius = 4
        self.sponsorsNameTextField.layer.cornerRadius = 4
        self.sponsorsPhoneNumberTextField.layer.cornerRadius = 4
        self.sponsorsEmailTextField.layer.cornerRadius = 4
        
        
        self.sponsorsNameTextField.layer.cornerRadius = 4
        self.sponsorsPhoneNumberTextField.layer.cornerRadius = 4
        self.sponsorsEmailTextField.layer.cornerRadius = 4
        
        textFieldsTextOffWhiteColor()
        
        //Place holder
        userNameTextField.attributedPlaceholder = NSAttributedString(string: "Your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        sponsorsNameTextField.attributedPlaceholder = NSAttributedString(string: "Support Person's Name", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        sponsorsPhoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "Support Person's Phone Number", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        
        sponsorsEmailTextField.attributedPlaceholder = NSAttributedString(string: "Support  Peronn's name", attributes: [NSAttributedString.Key.foregroundColor: MyColor.blackGrey.value])
        
        self.userNameTextField.autocorrectionType = .no
        self.sponsorsNameTextField.autocorrectionType = .no
        self.sponsorsPhoneNumberTextField.autocorrectionType = .no
        self.sponsorsEmailTextField.autocorrectionType = .no
        
        // Picker View
        self.aaPickerView.isHidden = true
        self.aaPickerView.dataSource = self
        self.aaPickerView.delegate = self
        
        //Background UI
        //Top view
        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        //Custom one based on mock up
        //Buttom view
        
        
        
        //Textfields
        textFieldsInactive()
        textFieldsInvisable()
        updateCurrentAAStep()
        
        UserController.shared.fetchCurrentUser { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.updateCurrentAAStep()
                    self.updateViews()
                }
                
            } else {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print("\n🤯 Error fechign Data \n")
                return
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("viewWillDisappear")
        // There's a glitch with this app
        //        editBool = false
        //        textFieldsInvisable()
        //        textFieldsInactive()
        //        self.cancelButton.isEnabled = false
        //        self.cancelButton.tintColor = .clear
        //        self.aaPickerView.alpha = 0.0
        //        self.aaPickerView.isHidden = true
        //        textFieldsTextOffWhiteColor()
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateViews() {
        
        guard let loggedInUser = UserController.shared.loggedInUser
            else { return }
        userNameTextField.text = loggedInUser.userName
        sponsorsNameTextField.text = loggedInUser.sponsorName
        sponsorsPhoneNumberTextField.text = loggedInUser.sponsorTelephoneNumber
        sponsorsEmailTextField.text = loggedInUser.sponsorEmail
        currentAAStepValueLabel.text = "\(loggedInUser.aaStep)"
    }
    
    // MARK: - Actions
    @IBAction func contactButtonTapped(_ sender: Any) {
        showContcts()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.phoneBookButton.isUserInteractionEnabled = false
        textFieldsInvisable()
        textFieldsInactive()
        self.cancelButton.isEnabled = false
        self.cancelButton.tintColor = .clear
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
            self.aaPickerView.alpha = 0.0
            self.phoneBookButton.alpha = 0
            
        }) { (succes) in
            if succes {
                self.aaPickerView.isHidden = true
                print("\nCase True animation compeleted\n")
            }
        }
        
        print("\nEdit Button Tapped")
        
        // Edit Button Bool
        editBool = false
        textFieldsTextOffWhiteColor()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
    }
    
    func textFieldsInactive() {
        userNameTextField.isUserInteractionEnabled = false
        sponsorsNameTextField.isUserInteractionEnabled = false
        sponsorsPhoneNumberTextField.isUserInteractionEnabled = false
        sponsorsEmailTextField.isUserInteractionEnabled = false
        
        //also include the UI Stuff
    }
    
    func textFieldsActive() {
        userNameTextField.isUserInteractionEnabled = true
        sponsorsNameTextField.isUserInteractionEnabled = true
        sponsorsPhoneNumberTextField.isUserInteractionEnabled = true
        sponsorsEmailTextField.isUserInteractionEnabled = true
        
        //also include the UI Stuff
    }
    
    func textfildsVisable() {
        userNameTextField.backgroundColor = .white
        sponsorsNameTextField.backgroundColor  = .white
        sponsorsPhoneNumberTextField.backgroundColor = .white
        sponsorsEmailTextField.backgroundColor = .white
        //current aa text field
    }
    
    func textFieldsInvisable() {
        userNameTextField.backgroundColor = .clear
        sponsorsNameTextField.backgroundColor = .clear
        sponsorsPhoneNumberTextField.backgroundColor = .clear
        sponsorsEmailTextField.backgroundColor = .clear
        //current aa text field
        
        userNameTextField.borderStyle = .none
        sponsorsNameTextField.borderStyle = .none
        sponsorsPhoneNumberTextField.borderStyle = .none
        sponsorsEmailTextField.borderStyle = .none
    }
    
    func textFieldsTextBlackColor() {
        //Text Field Text Color
        self.userNameTextField.textColor = .black
        self.sponsorsNameTextField.textColor = .black
        self.sponsorsPhoneNumberTextField.textColor = .black
        self.sponsorsEmailTextField.textColor = .black
        
    }
    
    func textFieldsTextOffWhiteColor() {
        //Text Field Text Color
        self.userNameTextField.textColor = MyColor.offWhite.value
        self.sponsorsNameTextField.textColor = MyColor.offWhite.value
        self.sponsorsPhoneNumberTextField.textColor = MyColor.offWhite.value
        self.sponsorsEmailTextField.textColor = MyColor.offWhite.value
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        switch editBool {
        case false:
            
            // Edit Button
            self.phoneBookDisappearAnimation()
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped(_:)))
            
            textFieldsTextBlackColor()
            
            self.cancelButton.isEnabled = true
            self.cancelButton.tintColor = nil
            
            // Picker View
            self.aaPickerView.alpha = 0
            self.aaPickerView.isHidden = false
            
            // Text Fields
            textFieldsActive()
            textfildsVisable()
            
            // Picker View
            UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseIn, animations: {
                self.aaPickerView.alpha = 1.0
            }) { (succes) in
                if succes {
                    self.aaPickerView.tintColor = .black
                    //Test Print
                    print("\nCase False animation compeleted\n")
                }
            }
            
            // Test Print
            print("\nEdit Button Tapped")
            
            // Edit Button Bool
            editBool = true
        case true:
            
            //activity indicator
            showStartActivityIndicator()
            
            //image anamation
            self.phoneBookAppearAnimation()
            
            self.cancelButton.isEnabled = false
            self.cancelButton.tintColor = .clear
            textFieldsInvisable()
            textFieldsInactive()
            textFieldsTextOffWhiteColor()
            
            guard let userName = userNameTextField.text,
                let sponsorName = sponsorsNameTextField.text,
                let sponsorTelephone = sponsorsPhoneNumberTextField.text,
                let sponsorEmail = sponsorsEmailTextField.text else { return }
            //use selectedAaStep bc that is the value that comes direclty from the picker
            let selectedAaStep = aaPickerView.selectedRow(inComponent: 1)
            currentAAStepValueLabel.text = "\(selectedAaStep)"
            // MARK: - CK Update
            if let loggedInUser = UserController.shared.loggedInUser {
                UserController.shared.updateUserDetails(user: loggedInUser, userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorTelephone, sponsorEmail: sponsorEmail, aaStep: Int(selectedAaStep)) { (success) in
                    
                    if success {
                        print("🙏🏽Success Updating Entry")
                        DispatchQueue.main.async {
                            self.updateCurrentAAStep()
                            self.hideStopActivityIndicator()
                        }
                    } else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        // prseent UI Alert expalining error
                        DispatchQueue.main.async {
                            self.present(self.networkErrorNotif, animated: true, completion: nil)
                        }
                        print("💀error with the upating the data")
                        return
                    }
                }
            } else {
                //Mark: - Create
                UserController.shared.createNewUserDetailsWith(userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorTelephone, sponsorEmail: sponsorEmail, aaStep: Int(selectedAaStep)) { (success) in
                    if success {
                        print("\n🙏🏽 Creating new userDetails to CK successful\n")
                        DispatchQueue.main.async {
                            self.hideStopActivityIndicator()
                        }
                    } else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        // prseent UI Alert expalining error
                        DispatchQueue.main.async {
                            self.present(self.networkErrorNotif, animated: true, completion: nil)
                        }
                        print("💀error with the upating the data")
                        return
                    }
                }
            }
            
            // Text Fields
            textFieldsInactive()
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
            
            // Picker View
            UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
                self.aaPickerView.alpha = 0.0
            }) { (succes) in
                if succes {
                    self.aaPickerView.isHidden = true
                    print("\nCase True animation compeleted\n")
                    DispatchQueue.main.async {
                        self.updateCurrentAAStep()
                    }
                }
            }
            print("\nEdit Button Tapped")
            // Edit Button Bool
            editBool = false
        }
    }
    
    
    func updateCurrentAAStep() {
        if currentAAStepValueLabel.text == "0" {
            currentAAStepValueLabel.isHidden = true
            aaStepImageView.isHidden = true
        } else {
            currentAAStepValueLabel.isHidden = false
            aaStepImageView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToLocationTVC" {
            guard let destinvationVC = segue.destination as? LocationTVC else {return}
            destinvationVC.user = UserController.shared.loggedInUser
        }
    }
    
}

extension HomeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0: return 1
            
        default: return 13
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "Step"
        default:
            return "\(row)"
        }
    }
    
    func hideStopActivityIndicator() {
        self.activityIndicator.isHidden =  true
        self.activityIndicator.stopAnimating()
    }
    
    func showStartActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
}

extension HomeVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case sponsorsPhoneNumberTextField:
            sponsorsPhoneNumberTextField.keyboardType = .namePhonePad
            print("spnosrs phone number text field selected")
        case sponsorsEmailTextField:
            sponsorsEmailTextField.keyboardType = .emailAddress
            print("sponsor email text field selected")
            
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
            sponsorsEmailTextField.becomeFirstResponder()
            
            
        default:
            sponsorsEmailTextField.resignFirstResponder()
            break
        }
        return false
    }
}

extension HomeVC {
    
    func phoneBookDisappearAnimation() {
        UIView.animate(withDuration: 1.0, animations: {
            DispatchQueue.main.async {
                
                self.phoneBookButton.alpha = 0
            }
        }) { (success) in
            if !success {
                self.phoneBookButton.isHidden = true
            }
        }
    }
    
    func phoneBookAppearAnimation() {
        
        UIView.animate(withDuration: 1.2, delay: 0.0, usingSpringWithDamping: 3, initialSpringVelocity: 2, options: [.curveEaseIn], animations: {
             DispatchQueue.main.async {
            self.phoneBookButton.setImage(self.phoneBookImage, for: .normal)
            self.phoneBookButton.alpha = 1
            }
        }) { (success) in
            if success {
                self.phoneBookButton.isUserInteractionEnabled = true
            } else {
                self.phoneBookButton.isHidden = true 
            }
        }
    }
}


extension HomeVC: CNContactPickerDelegate {
    
    func showContcts() {
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
        
        sponsorsEmailTextField.text = "\(emailString ?? "")"
    }
}

