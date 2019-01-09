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
    
    // MARK: - IBoutlets
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var sobrietySaveButton: UIButton!
    @IBOutlet var sobrietyDateView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var soberSinceLabel: UILabel!
    @IBOutlet weak var soberSinceDateValueLabel: UILabel!
    @IBOutlet weak var sobrietyDatePicker: UIDatePicker!
    @IBOutlet weak var numberOfDaysSoberLabel: UILabel!
    @IBOutlet weak var numberOfDaysSoberValueLabel: UILabel!
    
    var theme = MyTheme.dark
    var user: User?
    private let localeUSA = "en_US"
    private let sobrietyUserDefaultKey = "sobrietyUserDefaultKey"
    
    var sobrietyDate: Date? {
        return UserDefaults.standard.value(forKey: sobrietyUserDefaultKey) as? Date
    }
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        
        self.activityIndicatorView.isHidden = true 
        updateViewsRelatedToSobrietyItems()
        
        sobrietyDateView.layer.cornerRadius = 15
        soberSinceDateValueLabel.numberOfLines = 0
        modifiyDatePicker()
    
        self.activityIndicator.isHidden = true 
        
        soberSinceDateValueLabel.numberOfLines = 0
        
        super.viewDidLoad()
        
        view.addSubview(calenderView)
        
        self.view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        updateLabelUI()
        
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
    
    
    func updateViewsRelatedToSobrietyItems() {
        
        guard let sobrietyDate = sobrietyDate else { return }
        
        let userCalendar = Calendar.current
        
        let dateComponents = userCalendar.dateComponents([.day], from: sobrietyDate, to: Date())
        
        guard let numberOfDaysSober = dateComponents.day else { return }
        
        numberOfDaysSoberValueLabel.text = "\(numberOfDaysSober)"
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: localeUSA)
        dateFormater.timeStyle = .none
        dateFormater.dateStyle = .medium
        let formattedSobrietyDate = dateFormater.string(from: sobrietyDate)
        
        soberSinceDateValueLabel.text = formattedSobrietyDate
        
    }
    
    // MARK: - Actions
    
    @IBAction func sobrietySaveButtonTapped(_ sender: IRButton) {
        //TestPrint
        print("\nSave Button Tapped")
        
        UserDefaults.standard.setValue(sobrietyDatePicker.date, forKey: sobrietyUserDefaultKey)
        
        //Add a second user defaults to record/save the
        
        
        //set the date to the label
        
        
        updateViewsRelatedToSobrietyItems()
        
        animateOutOfSobrietyView()
        
    }
    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        print("Edit buton tapped")
        DispatchQueue.main.async {
            self.animateInSobrietyView()
        }
    }

    @IBAction func checkInButtonTapped(_ sender: Any) {
        let checkInAlertController = AlertController.presentActionSheetAlertControllerWith(alertTitle: nil, alertMessage: nil, dismissActionTitle: "Cancel")
        
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
        
        DispatchQueue.main.async {
            self.present(checkInAlertController, animated: true, completion: nil)
        }
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
            
                DispatchQueue.main.async {
                     self.present(notMailCompatable, animated: true)
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
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
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.present(composeEmail, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            DispatchQueue.main.async {
                controller.dismiss(animated: true, completion: nil)
            }
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
            DispatchQueue.main.async {
                self.present(notMailCompatable, animated: true, completion: nil)
            }
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
                //Test print
                print(loggedInUser.userName)
                print("\(loggedInUser.aaStep)")
            } else {
                print("\nUnable to fetch current user\n")
            }
        }
    }
}

extension CalendarVC {
    func animateOutOfSobrietyView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.sobrietyDateView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.sobrietyDateView.alpha = 0
            //            self.visualBlurrrView.effect = nil
        }) { (success: Bool) in
            self.sobrietyDateView.removeFromSuperview()
        }
    }
    
    func animateInSobrietyView() {
        self.view.addSubview(self.sobrietyDateView)
        self.sobrietyDateView.center = self.view.center
        
        self.sobrietyDateView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        self.sobrietyDateView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.sobrietyDateView.alpha = 1
            self.sobrietyDateView.transform = CGAffineTransform.identity
        }
    }
    
    func modifiyDatePicker() {
        sobrietyDatePicker.datePickerMode = .date
    }
}

extension CalendarVC {
    func updateLabelUI() {
//        soberSinceLabel.font = MyFont.sfDisplayMedium43.value
//        soberSinceDateValueLabel.font = MyFont.sfDisplayMedium43.value
//        numberOfDaysSoberLabel.font = MyFont.sFMedium17.value
//        numberOfDaysSoberValueLabel.font = MyFont.sFMedium17.value
    }
}

/*
    self.navigationController?.navigationBar.isTranslucent = false 
 
 //Future Versions will have themes
 //    @IBAction func themeButtonTapped(_ sender: UIBarButtonItem) {
 //        if theme == .dark {
 //            sender.title = "Dark"
 //            theme = .light
 //            Style.themeLight()
 //
 //        } else {
 //            sender.title = "Light"
 //            theme = .dark
 //            Style.themeDark()
 //
 //        }
 //        self.view.backgroundColor=Style.bgColor
 //        calenderView.changeTheme()
 //    }
 
 */
