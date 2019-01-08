//
//  CalendarVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import CloudKit
import MessageUI

enum MyTheme {
    case light
    case dark
}

class CalendarVC: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var daysSoberLabel: UILabel!
    //Use for future versions
    @IBOutlet weak var themeButton: UIBarButtonItem!
    @IBOutlet weak var daysSoberCountLabel: UILabel!
    
    @IBOutlet weak var restButton: UIButton!
    @IBAction func themeButtonTapped(_ sender: UIBarButtonItem) {
        if theme == .dark {
            sender.title = "Dark"
            theme = .light
            Style.themeLight()
            
        } else {
            sender.title = "Light"
            theme = .dark
            Style.themeDark()
            
        }
        self.view.backgroundColor=Style.bgColor
        calenderView.changeTheme()
    }
    
    var theme = MyTheme.dark
    var user: User?
    
    override func viewDidLoad() {
        
        self.activityIndicator.isHidden = true 
        
        daysSoberCountLabel.numberOfLines = 0
        
        
        super.viewDidLoad()
        //        self.title = "My Calender"
        self.navigationController?.navigationBar.isTranslucent = false
        
        updateSoberDate()
        
        self.view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        view.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        calenderView.heightAnchor.constraint(equalToConstant: 365).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    let calenderView: CalenderView = {
        let v = CalenderView(theme: MyTheme.dark)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    func updateSoberDate() {
        
        let today = Date()
        //        let currentDay = NSDateComponents.current
        let nextDay = today.add(days: 1)
        
        //        daysSoberCountLabel.text = "\(nextDay?.compare(today))"
        daysSoberCountLabel.text = "\(nextDay)"
        print("\nDays Sober Count:\(daysSoberCountLabel.text)")
    }
    
    // MARK: - Actions
    @IBAction func checkInButtonTapped(_ sender: Any) {
        let checkInAlertController = AlertController.presentAlertControllerWith(alertTitle: "Check in", alertMessage: "Check in with your accountability person", dismissActionTitle: "Cancel")
        
        let composeEmailAction = UIAlertAction(title: "Email \(user?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
            self.composeEmail()
        }
        
        let composeTextAction = UIAlertAction(title: "Text \(user?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
            self.composeTextMessage()
        }
        
        let phoneCallAction = UIAlertAction(title: "Call \(user?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
            self.telephoneSponsor()
        }
        
        [composeEmailAction, phoneCallAction, composeTextAction].forEach { checkInAlertController.addAction($0)}
        
        present(checkInAlertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    
    @IBAction func restButtonTapped(_ sender: UIButton) {
    }
    @IBAction func resetButtonTapped(_ sender: Any) {
        //Test Print
        print("current days sober: \(daysSoberCountLabel.description)")
        daysSoberCountLabel.text = "\(0)"
    }
    
}

// MARK: - Email
extension CalendarVC: MFMailComposeViewControllerDelegate {
    
    func composeEmail() {
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        //check if device can send mail
        guard MFMailComposeViewController.canSendMail() else {
            
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing E-Mail", alertMessage: "Your device does not support this feature", dismissActionTitle: "OK")
            present(notMailCompatable, animated: true) {
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                }
            }
            return
        }
        fetchCurrentuser()
        
        let composeEmail = MFMailComposeViewController()
        composeEmail.mailComposeDelegate = self
        composeEmail.setToRecipients(["\(UserController.shared.loggedInUser?.sponsorEmail ?? "")"])
        composeEmail.setSubject("Check-In")
        composeEmail.setMessageBody("Hi there, I just wanted to check in and give you a quick update.", isHTML: false)
        
        DispatchQueue.main.async {
            self.present(composeEmail, animated: true)
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            
            }
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
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
               self.activityIndicator.stopAnimating()
            }
        case .saved:
            print("🐦🐦🐦mail savied")
        case .sent:
            print("🐦🐦🐦mail saved")
        }
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Text Message
extension CalendarVC: MFMessageComposeViewControllerDelegate {
    
    
    func composeTextMessage() {
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        guard MFMessageComposeViewController.canSendText() else {
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing Text Message", alertMessage: "At this time, your device does not support this feature", dismissActionTitle: "OK")
            present(notMailCompatable, animated: true, completion: nil)
            return
        }
        
        fetchCurrentuser()
        
        let composeText = MFMessageComposeViewController()
        composeText.messageComposeDelegate = self
        
        composeText.recipients = ["\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "")"]
        composeText.body = "Hi \(UserController.shared.loggedInUser?.sponsorName ?? "Friend"),\n\njust wanted to check in and give you an update."
        
        present(composeText, animated: true) {
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
        case .failed:
            controller.dismiss(animated: true, completion: nil)
        case .sent:
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
}

// MARK: - Telephone
extension CalendarVC {
    
    func telephoneSponsor() {
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.startAnimating()
        }
        fetchCurrentuser()
        guard let phoneCallURL = URL(string: "telprompt://\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "7142510446")") else {
            let phoneCallError = AlertController.presentAlertControllerWith(alertTitle: "Error Making Phone Call", alertMessage: "Unexpected error please try again later", dismissActionTitle: "OK")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.present(phoneCallError, animated: true, completion: nil)
            }
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(phoneCallURL)
        }
    }
}

extension CalendarVC {
    
    func fetchCurrentuser() {
        UserController.shared.fetchCurrentUser { (success, _) in
            if success {
                guard let loggedInUser = UserController.shared.loggedInUser
                    else { return }
                print(loggedInUser.userName)
                print(loggedInUser.sponsorName)
                print(loggedInUser.sponsorTelephoneNumber)
                print(loggedInUser.sponsorEmail)
                print("\(loggedInUser.aaStep)")
                
            } else {
                print("\nUnable to fetch current user\n")
            }
        }
    }
}
