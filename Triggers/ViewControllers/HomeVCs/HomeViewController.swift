//
//  HomeViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var currentAaStepLabel: UILabel!
    @IBOutlet weak var aaPickerView: UIPickerView!
    @IBOutlet weak var locationButton: UIButton!
    
    //TextFields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var sponsorNameTextField: UITextField!
    @IBOutlet weak var sponsorsPhoneNumberTextField: UITextField!
    @IBOutlet weak var sponsorEmailTextField: UITextField!
    
    //Activity Indicator
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!

    var editBool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard
        self.view.endEditing(true)
        
        //Activity Spinner
//        self.activityIndicatorOutlet.isHidden = false
        self.activityIndicatorOutlet.startAnimating()
        
        // Picker View
        self.aaPickerView.isHidden = true
        self.aaPickerView.dataSource = self
        self.aaPickerView.delegate = self
        
        //Background UI
        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        // MARK: - This is coming back Nill
        // ASK: - Look inot why its nil or why it returns
        
        UserController.shared.fetchCurrentUser() { (success, error) in
            if success {
                DispatchQueue.main.async {
                    self.activityIndicatorOutlet.isHidden = false
                    self.activityIndicatorOutlet.stopAnimating()
                    self.updateViews()
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.activityIndicatorOutlet.stopAnimating()
                    self.activityIndicatorOutlet.isHidden = true
                    print("\n🤯 Error fechign Data \n")
                    //present UI Alert that there was an error loading
                    return
                }
            }
        }
    }
    
    func updateViews() {
        
        guard let loggedInUser = UserController.shared.loggedInUser
            else { return }
        userNameTextField.text = loggedInUser.userName
        sponsorNameTextField.text = loggedInUser.sponsorName
        sponsorsPhoneNumberTextField.text = loggedInUser.sponsorTelephoneNumber
        sponsorEmailTextField.text = loggedInUser.sponsorEmail
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
    
    func textFieldsInactiveFalse(){
        userNameTextField.isUserInteractionEnabled = false
        sponsorNameTextField.isUserInteractionEnabled = false
        sponsorsPhoneNumberTextField.isUserInteractionEnabled = false
        sponsorEmailTextField.isUserInteractionEnabled = false
        
        //also include the UI Stuff
    }
    
    func textFieldsInactiveTrue(){
        userNameTextField.isUserInteractionEnabled = true
        sponsorNameTextField.isUserInteractionEnabled = true
        sponsorsPhoneNumberTextField.isUserInteractionEnabled = true
        sponsorEmailTextField.isUserInteractionEnabled = true
        
        //also include the UI Stuff
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        switch editBool {
        case false:
            // Edit Button
            editButton.setTitle("Done", for: .normal)
            
            // Picker View
            self.aaPickerView.alpha = 0
            self.aaPickerView.isHidden = false
            
            // Text Fields
            textFieldsInactiveTrue()
            
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
            
            guard let userName = userNameTextField.text,
                let sponsorName = sponsorNameTextField.text,
                let sponsorTelephone = sponsorsPhoneNumberTextField.text,
                let sponsorEmail = sponsorEmailTextField.text,
                let currentStep = currentAaStepLabel.text else {return}
            
            sponsorNameTextField.resignFirstResponder()
            
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
                        print("💀error with the upating the data")
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
                        print("💀error with the upating the data")
                        return
                    }
                }
            }
            
            
            
            
            // Text Fields
            textFieldsInactiveFalse()
            
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

extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
