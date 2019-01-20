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
        
        self.activityIndicatorView.isHidden = true
        updateViewsRelatedToSobrietyItems()
        updateDayofWeekLabel()
        sobrietyDateView.layer.cornerRadius = 15
        soberSinceDateValueLabel.numberOfLines = 0
        modifiyDatePicker()
        
        self.activityIndicator.isHidden = true
        
        //UI
        self.view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        updateLabelUI()
        
        //Check in button
        checkInBottomButton.setTitle("Check-In", for: .normal)
//        checkInBottomButton.setTitleColor(MyColor.blackGrey.value, for: .normal)
//        checkInBottomButton.backgroundColor = MyColor.offWhite.value
        
        
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
        let v = CalenderView(theme: MyTheme.dark)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
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
        //        let kernAttribute = [NSAttributedString.Key.kern: 10]
        
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
        //TestPrint
        print("\nSave Button Tapped")
        
        //Turn the button to a cancel button
       
        
        UserDefaults.standard.setValue(sobrietyDatePicker.date, forKey: sobrietyUserDefaultKey)
        
        updateViewsRelatedToSobrietyItems()
        updateDayofWeekLabel()
        animateOutOfSobrietyView()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        print("Edit buton tapped")
        checkInBottomButton.isEnabled = false
        DispatchQueue.main.async {
             self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.animateOutOfSobrietyView))
            self.animateInSobrietyView()
        }
    }
    
    
    @objc func cancelSobrietyDateSelection() {
        
    }
    
    @IBAction func checkInButtonTapped(_ sender: IRButton) {
        
        //Test print
        print("checkInBottomButtonTapped tapped")
        let checkInAlertController = AlertController.presentActionSheetAlertControllerWith(alertTitle: nil, alertMessage: nil, dismissActionTitle: "Cancel")
        
        let supportPerson = UserController.shared.loggedInUser
        
        let composeEmailAction = UIAlertAction(title: "Email \(supportPerson?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
            self.composeEmail()
        }
        
        let composeTextAction = UIAlertAction(title: "Text \(supportPerson?.sponsorName ?? "Your Support Person")", style: .default) { (_) in
            self.composeTextMessage()
        }
        
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

//Test print to verify the custom San Francisco fonts are include in this projects build
//        for family: String in UIFont.familyNames
//        {
//            print(family)
//            for names: String in UIFont.fontNames(forFamilyName: family)
//            {
//                print("== \(names)")
//            }
//        }
