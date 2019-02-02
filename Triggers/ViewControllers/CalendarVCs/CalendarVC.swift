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

//Dark and light theme will be implemented in a future version
enum MyTheme {
    case light
    case dark
}

// NOTE: The Calendar in this app will soon be replaced by a cocoapod
class CalendarVC: UIViewController, UINavigationBarDelegate {
    
    // MARK: - IBoutlets
    @IBOutlet weak var triggersLabel: UILabel!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var sobrietySaveButton: UIButton!
    @IBOutlet var sobrietyDateView: UIView!
    @IBOutlet weak var soberSinceWeekDayLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var soberSinceLabel: UILabel!
    @IBOutlet weak var soberSinceYearValueLabel: UILabel!
    @IBOutlet weak var soberSinceDateValueLabel: UILabel!
    @IBOutlet weak var sobrietyDatePicker: UIDatePicker!
    @IBOutlet weak var numberOfDaysSoberLabel: UILabel!
    @IBOutlet weak var numberOfDaysSoberValueLabel: UILabel!
    @IBOutlet weak var triggersLogoView: UIImageView!
    @IBOutlet weak var checkInBottomButton: UIButton!
    
    //Stalk View
    @IBOutlet weak var soberietyUserInfoLRStack: UIStackView!
    
    var theme = MyTheme.dark
    var user: User?
    private let localeUSA = "en_US"
    private let sobrietyUserDefaultKey = "sobrietyUserDefaultKey"
    
    var sobrietyDate: Date? {
        return UserDefaults.standard.value(forKey: sobrietyUserDefaultKey) as? Date
    }
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        //
        
        triggersLabel.textColor = MyColor.offWhite.value
        triggersLabel.text = "My Triggers"
        triggersLogoView.image = UIImage(named: "triggersLogoIcon")
        checkInBottomButton.isUserInteractionEnabled = true
        rightView.backgroundColor = .clear
        rightView.layer.borderWidth = 0.5
        rightView.layer.borderColor = MyColor.offWhite.value.cgColor
        
        leftView.backgroundColor = .clear
        leftView.layer.borderWidth = 0.5
        leftView.layer.borderColor = UIColor.black.cgColor
        leftView.layer.borderColor = MyColor.offWhite.value.cgColor
        
        updateViewsFonts()
        
        view.addSubview(calenderView)
        
        self.activityIndicatorView.backgroundColor = .clear
        updateViewsRelatedToSobrietyItems()
        updateDayofWeekLabel()
        sobrietyDateView.layer.cornerRadius = 15
        soberSinceDateValueLabel.numberOfLines = 0
        modifiyDatePicker()
        
        self.activityIndicator.isHidden = true
        
        //UI
        self.view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        //Check in button
        checkInBottomButton.setTitle("Check-In", for: .normal)
        
        calenderView.topAnchor.constraint(equalTo: self.soberietyUserInfoLRStack.bottomAnchor, constant: 18).isActive = true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        calenderView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        checkInBottomButton.isEnabled = true
        animateOutOfSobrietyView()
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    let calenderView: CalenderView = {
        
        let cView = CalenderView(theme: MyTheme.dark)
        cView.translatesAutoresizingMaskIntoConstraints = false
        
        return cView
    }()
    
    func updateViewsRelatedToSobrietyItems() {
        
        guard let usersSobrietyDate = sobrietyDate else { return }
        
        let userCalendar = Calendar.current
        
        let dateComponents = userCalendar.dateComponents([.day], from: usersSobrietyDate, to: Date())
        
        guard let numberOfDaysSober = dateComponents.day else { return }
        
        numberOfDaysSoberValueLabel.text = "\(numberOfDaysSober)"
        
        let dateFormater = DateFormatter()
        
        let usaLocal = Locale(identifier: localeUSA)
        dateFormater.locale = usaLocal
        
        dateFormater.timeStyle = .none
        dateFormater.dateStyle = .short
        
        //custom formats
        let monthDayType = "MMMMdd"
        
        let monthDayFormat = DateFormatter.dateFormat(fromTemplate: monthDayType, options: 0, locale: usaLocal)
        
        dateFormater.dateFormat = monthDayFormat
        
        let sobrietyMonthDayValue = dateFormater.string(from: usersSobrietyDate)
        
        //Year only format
        let yearofSobrietyComponent = userCalendar.dateComponents([.year, .weekday], from: usersSobrietyDate)
        
        let yearOfSobreity = yearofSobrietyComponent.year
        
        soberSinceDateValueLabel.text = sobrietyMonthDayValue
        soberSinceYearValueLabel.text = "\(yearOfSobreity ?? 0)"
    }
    
    func updateDayofWeekLabel() {
        
        guard let usersSobrietyDate = sobrietyDate else { return }
        
        let dayOfWeekType = "EEEE"
        let dateFormater = DateFormatter()
        let usaLocal = Locale(identifier: localeUSA)
        let dayNameFormat = DateFormatter.dateFormat(fromTemplate: dayOfWeekType, options: 0, locale: usaLocal)
        
        dateFormater.dateFormat = dayNameFormat
        let dayNameValue = dateFormater.string(from: usersSobrietyDate)
        soberSinceWeekDayLabel.text = "\(dayNameValue)"
    }
    
    func updateViewsFonts() {
        
        //Future version include 'kern' to text style
        //let kernAttribute = [NSAttributedString.Key.kern: 10]
        
        //Left side date related to Sober Since
        soberSinceLabel.font = MyFont.SFDisMed.withSize(size: 17)
        soberSinceYearValueLabel.font = MyFont.SFBold.withSize(size: 24)
        soberSinceDateValueLabel.font = MyFont.SFDisMed.withSize(size: 17)
        soberSinceWeekDayLabel.font = MyFont.SFReg.withSize(size: 12)
        
        //Right side date related to Counter of days sober
        numberOfDaysSoberLabel.font = MyFont.SFDisMed.withSize(size: 17)
        numberOfDaysSoberValueLabel.font = MyFont.SFBold.withSize(size: 24)
        
        soberSinceLabel.textColor = MyColor.offWhite.value
        soberSinceYearValueLabel.textColor = MyColor.offWhite.value
        soberSinceDateValueLabel.textColor = MyColor.offWhite.value
        soberSinceWeekDayLabel.textColor = MyColor.offWhite.value
        
        //Right side date related to Counter of days sober
        numberOfDaysSoberLabel.textColor = MyColor.offWhite.value
        numberOfDaysSoberValueLabel.textColor = MyColor.offWhite.value
    }
    
    
    // MARK: - Actions
    @IBAction func sobrietySaveButtonTapped(_ sender: IRButton) {
        
        UserDefaults.standard.setValue(sobrietyDatePicker.date, forKey: sobrietyUserDefaultKey)
        
        updateViewsRelatedToSobrietyItems()
        updateDayofWeekLabel()
        animateOutOfSobrietyView()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        checkInBottomButton.isEnabled = false
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.animateOutOfSobrietyView))
            self.animateInSobrietyView()
        }
    }
    
    @IBAction func checkInButtonTapped(_ sender: IRButton) {
        
        //Initial check to verify that the user's accountability partners inforamtion is saved
        if UserController.shared.loggedInUser?.sponsorEmail == "" && UserController.shared.loggedInUser?.sponsorTelephoneNumber == "" ||   UserController.shared.loggedInUser?.sponsorEmail == nil && UserController.shared.loggedInUser?.sponsorTelephoneNumber == nil {
            let noSponsorInfoFoundALert = AlertController.presentAlertControllerWith(alertTitle: "Error Obtaining Information", alertMessage: "There seems to be an issue obtaining your support person's email and phone number. Click on the 'Information' tab and ensure that their information is correctly saved", dismissActionTitle: "Ok")
            DispatchQueue.main.async {
                
                self.present(noSponsorInfoFoundALert, animated: true, completion: nil)
            }
        } else {
            
            let checkInAlertController = AlertController.presentActionSheetAlertControllerWith(alertTitle: nil, alertMessage: nil, dismissActionTitle: "Cancel")
            
            let supportPerson = UserController.shared.loggedInUser
            
            //Eamil
            if supportPerson?.sponsorName == "" {
                
                let composeEmailAction = UIAlertAction(title: "Email Your Support Person", style: .default) { (_) in
                    
                    self.composeEmail()
                }
                // Text
                let composeTextAction = UIAlertAction(title: "TextYour Support Person", style: .default) { (_) in
                    self.composeTextMessage()
                }
                //Call
                let phoneCallAction = UIAlertAction(title: "CallYour Support Person", style: .default) { (_) in
                    self.telephoneSponsor()
                }
                
                [composeEmailAction, phoneCallAction, composeTextAction].forEach { checkInAlertController.addAction($0)}
                
                DispatchQueue.main.async {
                    checkInAlertController.popoverPresentationController?.sourceView = self.view
                    checkInAlertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                    checkInAlertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    
                    self.present(checkInAlertController, animated: true, completion: nil)
                }
            } else {
                
                let composeEmailAction = UIAlertAction(title: "Email \(supportPerson?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
                    
                    self.composeEmail()
                }
                // Text
                let composeTextAction = UIAlertAction(title: "Text \(supportPerson?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
                    DispatchQueue.main.async {
                        self.showStartActivityIndicator()
                    }
                    self.composeTextMessage()
                }
                //Call
                let phoneCallAction = UIAlertAction(title: "Call \(supportPerson?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
                    self.telephoneSponsor()
                }
                
                [composeEmailAction, phoneCallAction, composeTextAction].forEach { checkInAlertController.addAction($0)}
                
                DispatchQueue.main.async {
                    checkInAlertController.popoverPresentationController?.sourceView = self.view
                    checkInAlertController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                    checkInAlertController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    self.present(checkInAlertController, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - Email
extension CalendarVC: MFMailComposeViewControllerDelegate {
    
    func composeEmail() {
        
        //check if device can send mail
        guard MFMailComposeViewController.canSendMail() else {
            
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing E-Mail", alertMessage: "Your device does not support this feature", dismissActionTitle: "OK")
            
            DispatchQueue.main.async {
                self.present(notMailCompatable, animated: true)
                self.hideStopActivityIndictor()
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
            self.hideStopActivityIndictor()
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
                self.hideStopActivityIndictor()
            }
        case .saved:
            print("🐦🐦🐦mail savied")
        case .sent:
            print("🐦🐦🐦mail saved")
        }
        
        DispatchQueue.main.async {
            self.hideStopActivityIndictor()
            controller.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Text Message
extension CalendarVC: MFMessageComposeViewControllerDelegate {
    
    func composeTextMessage() {
        
        guard MFMessageComposeViewController.canSendText() else {
            // DO some UI to show that an email cant be sent
            let notMailCompatable = AlertController.presentAlertControllerWith(alertTitle: "Error Composing Text Message", alertMessage: "At this time, your device does not support this feature", dismissActionTitle: "OK")
            DispatchQueue.main.async {
                self.hideStopActivityIndictor()
                self.present(notMailCompatable, animated: true, completion: nil)
            }
            return
        }
        
        self.showStartActivityIndicator()
        
        fetchCurrentuser()
        
        let composeText = MFMessageComposeViewController()
        composeText.messageComposeDelegate = self
        
        composeText.recipients = ["\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "")"]
        composeText.body = "Hi \(UserController.shared.loggedInUser?.sponsorName ?? "Friend"),\n\njust wanted to check in and give you an update."
        
        DispatchQueue.main.async {
            self.hideStopActivityIndictor()
            self.present(composeText, animated: true)
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
            self.showStartActivityIndicator()
        }
        fetchCurrentuser()
        
        guard let phoneCallURL = URL(string: "telprompt://\(UserController.shared.loggedInUser?.sponsorTelephoneNumber ?? "")") else {
            let phoneCallError = AlertController.presentAlertControllerWith(alertTitle: "Error Making Phone Call", alertMessage: "Unexpected error please try again later", dismissActionTitle: "OK")
            
            DispatchQueue.main.async {
                self.hideStopActivityIndictor()
                self.present(phoneCallError, animated: true, completion: nil)
            }
            return
        }
        DispatchQueue.main.async {
            self.hideStopActivityIndictor()
            UIApplication.shared.open(phoneCallURL)
        }
    }
}

// MARK: - Fetch
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
    @objc func
        animateOutOfSobrietyView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.sobrietyDateView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.sobrietyDateView.alpha = 0
            //            self.visualBlurrrView.effect = nil
        }) { (success: Bool) in
            self.sobrietyDateView.removeFromSuperview()
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editButtonTapped(_:)))
            }
            self.checkInBottomButton.isEnabled = true
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
    
    func showStartActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func hideStopActivityIndictor() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}

// NOTE: - Future version code below
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

//Test print to verify the custom San Francisco fonts are include in this projects build
//        for family: String in UIFont.familyNames
//        {
//            print(family)
//            for names: String in UIFont.fontNames(forFamilyName: family)
//            {
//                print("== \(names)")
//            }
//        }
