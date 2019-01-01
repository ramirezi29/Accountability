//
//  HomeViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import AVFoundation

class HomeVC: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var currentAaStepLabel: UILabel!
    @IBOutlet weak var aaPickerView: UIPickerView!
    @IBOutlet weak var locationButton: UIButton!
    
    //TextFields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var sponsorsNameTextField: UITextField!
    @IBOutlet weak var sponsorsPhoneNumberTextField: UITextField!
    @IBOutlet weak var sponsorsEmailTextField: UITextField!
    
    //Activity Indicator
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    
    //    @IBOutlet var tapGestureOutlet: UITapGestureRecognizer!
    
    var editBool = false
    
    let networkErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Unable able to Save Entry", alertMessage: "The Internet connection appears to be offline", dismissActionTitle: "OK")
    let fetchErrorNotif  = AlertController.presentAlertControllerWith(alertTitle: "Unable to load data", alertMessage: "The Internet connection appears to be offline", dismissActionTitle: "OK")
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        // Location
        updateLocationButton()
        
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
        
        //Keyboard
        //        self.view.endEditing(true)
        
        //Activity Spinner
        //        self.activityIndicatorOutlet.isHidden = false
        self.activityIndicatorOutlet.startAnimating()
        
        // Picker View
        self.aaPickerView.isHidden = true
        self.aaPickerView.dataSource = self
        self.aaPickerView.delegate = self
        
        //Background UI
        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        //Textfields
        textFieldsInactive()
        textFieldsInvisable()
        
        // MARK: - This is coming back Nill
        // ASK: - Look inot why its nil or why it returns
        
        UserController.shared.fetchCurrentUser() { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.activityIndicatorOutlet.isHidden = true
                    self.activityIndicatorOutlet.stopAnimating()
                    self.updateViews()
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.activityIndicatorOutlet.stopAnimating()
                    self.activityIndicatorOutlet.isHidden = true
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    // prseent UI Alert expalining error
                    self.present(self.fetchErrorNotif, animated: true, completion: nil)
                    //present UI Alert that there was an error loading
                }
                print("\n🤯 Error fechign Data \n")
                return
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
 //
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
        currentAaStepLabel.text = "\(loggedInUser.aaStep)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // NOTE: - In order to prevent the onboarding walk through from coming up again
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        // Will take you to the onboarding storyboard if user defaults hasnt been hit above
        let storyboard = UIStoryboard(name: "WalkThroughOnBoarding", bundle: nil)
        
        if let walkThroughVC = storyboard.instantiateViewController(withIdentifier: "WalkThroughVC") as? WalkThroughVC {
            present(walkThroughVC, animated: true, completion: nil)
        }
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

    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        switch editBool {
        case false:
            // Edit Button
            editButton.setTitle("Done", for: .normal)
            
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
            //Textfield
            textFieldsInvisable()
            textFieldsInactive()
            
            guard let userName = userNameTextField.text,
                let sponsorName = sponsorsNameTextField.text,
                let sponsorTelephone = sponsorsPhoneNumberTextField.text,
                let sponsorEmail = sponsorsEmailTextField.text,
                let currentStep = currentAaStepLabel.text else {return}
            
            // MARK: - CK Update
            if let loggedInUser = UserController.shared.loggedInUser {
                UserController.shared.updateUserDetails(user: loggedInUser, userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorTelephone, sponsorEmail: sponsorEmail, aaStep: Int(currentStep) ?? 1) { (success) in
                    
                    if success {
                        print("🙏🏽Success Updating Entry")
                        DispatchQueue.main.async {
                            // do any UI Stuff as a rsult of a successfully update
                        }
                    } else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        // prseent UI Alert expalining error
                        DispatchQueue.main.async {
                            self.present(self.networkErrorNotif, animated: true, completion: nil)
                            print("💀error with the upating the data")
                        }
                        return
                    }
                }
            } else {
                //Mark: - Create
                UserController.shared.createNewUserDetailsWith(userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorTelephone, sponsorEmail: sponsorEmail, aaStep: Int(currentStep) ?? 1) { (success) in
                    if success {
                        print("\n🙏🏽 Creating new userDetails to CK successful\n")
                        DispatchQueue.main.async {
                            // Do some UI Stuff if a record is saved successfully
                        }
                    } else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        // prseent UI Alert expalining error
                        self.present(self.networkErrorNotif, animated: true, completion: nil)
                        print("💀error with the upating the data")
                        return
                    }
                }
            }
            
            // Text Fields
            textFieldsInactive()
            
            // pass the Picker View Data to the Step Label
            let selectedAaStep = aaPickerView.selectedRow(inComponent: 1) + 1
            currentAaStepLabel.text = "\(selectedAaStep)"
            
            // Edit Button
            editButton.setTitle("Edit", for: .normal)
            
            // Picker View
            UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn, animations: {
                self.aaPickerView.alpha = 0.0
            }) { (succes) in
                if succes {
                    self.aaPickerView.isHidden = true
                    print("\nCase True animation compeleted\n")
                }
            }
            
            print("\nEdit Button Tapped")
            
            // Edit Button Bool
            editBool = false
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
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
            
        default: return 12
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "Step"
        default:
            return "\(row + 1) "
        }
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
    func updateLocationButton() {
        let locationIcon = UIImage(imageLiteralResourceName: "cursor")
        locationButton.setImage(locationIcon, for: .normal)
    }
}
