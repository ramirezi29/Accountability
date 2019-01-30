//
//  WalkThroughVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

protocol SaveUserInfoDelegate: class {
    func saveInfoToCloudKit(_ sender: WalkThroughVC, completion: @escaping (Bool) -> Void)
}

//Bottom VC
class WalkThroughVC: UIViewController, WalkthroughPageViewControllerDelegate {
    
    // MARK: - Oulets
    @IBOutlet var bossViewOutlet: UIView!
    @IBOutlet weak var buttomViewOutlet: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 10.0
            nextButton.layer.masksToBounds = true
            nextButton.backgroundColor = MyColor.annotationOrange.value
            nextButton.setTitleColor(MyColor.offWhite.value, for: .normal)
        }
    }
    
    @IBOutlet var skipButton: UIButton!
    
    weak var saveInfoDelegate: SaveUserInfoDelegate?
    
    var walkThroughPVC: WalkThroughPVC?
    var disableOnBardingBool = false
    var disableOnboardingKey = "disableOnboardingKey"
    var walkThroughCVC: WalkThroughContentVC?
    var hasSeenPermissions = false
    var user: User?
    var walkThroughContentVC: WalkThroughContentVC?
    
    //Landing Pad
    var userName: String?
    var sponsorName: String?
    var sponsorPhone: String?
    var sponsorEmail: String?
    var aaStep: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // user defualts
        
        //Button
        nextButton.alpha = 0
        
        //Get the users info in order to check if an account already exists
        loadUserDefaults()
        
        //In order to not present the onboarding screen
        if disableOnBardingBool == true  {
            presentMainView()
            
            // NOTE: - Not sure if this is needed return
            return
        }
        
        //View
        buttomViewOutlet.backgroundColor = MyColor.offWhite.value
        bossViewOutlet.backgroundColor = MyColor.powderBlue.value
        
        // index
        let index = walkThroughPVC?.currentIndex
        print("\nThe View just loaded and you are on index: \(String(describing: index))\n")
        
        // Next button
        nextButton.isHidden = false
        
        // Page Control
        pageControl.currentPageIndicatorTintColor = MyColor.hardBlue.value
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = 9
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadUserDefaults(){
        disableOnBardingBool = UserDefaults.standard.bool(forKey: disableOnboardingKey)
    }
    
    func updateUI() {
        if let index = walkThroughPVC?.currentIndex {
            print("\(String(describing: walkThroughPVC?.currentIndex))")
            
            switch index {
            case 4:
                print("case 4 was called")
                //                nextButton.setTitle("Next", for: .normal)
                self.nextButton.alpha = 0
                
            case 5:
                self.nextButton.alpha = 1.0
                if UserController.shared.loggedInUser == nil {
                    self.nextButton.setTitle("Save", for: .normal)
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                        
                        self.nextButton.alpha = 1.0
                    }, completion: nil)
                } else {
                    self.nextButton.alpha = 0.0
                    //                    self.nextButton.setTitle("Next", for: .normal)
                    //                     self.nextButton.setTitle("Thers a user", for: .normal)
                }
                
            case 6:
                nextButton.setTitle("I Understand", for: .normal)
                UIView.animate(withDuration: 1.0, delay: 0.4, options: [.curveEaseOut], animations: {
                    
                    self.nextButton.alpha = 1.0
                }, completion: nil)
                
                print("Case 5")
                
            case 7:
                self.nextButton.alpha = 0
                //                UIView.animate(withDuration: 0.9, delay: 0.1, options: [.curveEaseOut], animations: {
                //                    self.nextButton.backgroundColor =  MyColor.hardBlue.value
                //
                //                }, completion: nil)
                //
                //                nextButton.setTitle("Next", for: .normal)
                //
                //                UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
                //                    self.nextButton.alpha = 1.0
                //                }, completion: nil)
                print("case 7")
                
            case 8:
                nextButton.setTitle("GET STARTED", for: .normal)
                
                print("the Walk Through PVC hit the last case which is 6 and the index is \(index)")
                nextButton.isEnabled = true
                nextButton.isHidden = false
                
                UIView.animate(withDuration: 1.0, delay: 0.4, options: [.curveEaseOut], animations: {
                    
                    self.nextButton.alpha = 1.0
                }, completion: nil)
                
                
            default: break
                
            }
            pageControl.currentPage = index
        }
    }
    
    func presentMainView() {
        let calendarStoryboard = UIStoryboard(name: StoryboardConstants.mainStoryboard, bundle: nil).instantiateInitialViewController()!
        
        UIApplication.shared.keyWindow?.rootViewController = calendarStoryboard
        
        
        present(calendarStoryboard, animated: true, completion: nil)
        
    }
    
    func didUpdatePageIndex(currentIndex: Int) {
        let contentVC = walkThroughPVC!.currentVC!
        contentVC.delegate = self
        
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageViewController = destination as? WalkThroughPVC {
            walkThroughPVC = pageViewController
            walkThroughPVC?.walkthroughDelegate = self
        }
    }
    
    @IBAction func saveSaveButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if let index = walkThroughPVC?.currentIndex {
            
            switch index {
            case 0...4:
                walkThroughPVC?.forwardPage()
                
            case 5:
                
                delegateSaveToCK { (success) in
                    if success {
  print("🐶 Successfully saved to cloudkit yay 🔥")
                    } else {
                        print("\nError saving to cloud kit")
                    }
                }
                //                walkThroughPVC?.currentVC?.saveInfoToCloudKit(completion: { (success) in
                //                    if success {
                //
                //                     user?.userName =   walkThroughPVC?.currentVC?.userNameTextField.text
                //                    user?.userName =     walkThroughPVC?.currentVC?.sponsorsNameTextField.text
                //                        walkThroughPVC?.currentVC?.sponsorsPhoneNumberTextField.text
                //                        walkThroughPVC?.currentVC?.sponsorsPhoneNumberTextField.text
                //                        walkThroughPVC?.currentVC?.sponsorsEmailAddressTextField.text
                //
                //                        DispatchQueue.main.async {
                //
                //                        }
                //                    }
                //                })
                self.walkThroughPVC?.forwardPage()
                
                print("case 4")
                
            case 6:
                
                walkThroughPVC?.forwardPage()
                print("case 5")
                
            case 7:
                walkThroughPVC?.forwardPage()
                
            case 8:
                if UserController.shared.loggedInUser == nil {
                    walkThroughPVC?.currentVC?.saveInfoToCloudKit(completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                
                            }
                        }
                    })
                }
                
                UserDefaults.standard.set(true, forKey: UserDefaultConstants.isOnboardedKey)
                
                presentMainView()
                
                
            default: break
                
            }
            print("\n♦️ you are on case number: \(String(describing: walkThroughPVC?.currentIndex))")
        }
        updateUI()
    }
}

extension WalkThroughVC : WalkThroughContentVCDelegate {
//    func validUserNameEntered(username: String, isHidden: Bool) {
//        print("Random")
//    }
////}


    func validUserNameEntered(username: String, isHidden: Bool) {

        switch isHidden {
        case true:
            nextButton.isEnabled = true
            nextButton.isHidden = isHidden

            UIView.animate(withDuration: 0.8, delay: 0.1, options: [], animations: {
                self.nextButton.alpha = 0.0
            }, completion: nil)

        case false:
            nextButton.isHidden = isHidden

            UIView.animate(withDuration: 0.8, delay: 0.1, options: [], animations: {
                self.nextButton.alpha = 1.0
            }, completion: nil)

            nextButton.setTitle("GET STARTED", for: .normal)
        }
    }
}

extension WalkThroughVC {
    
    func delegateSaveToCK(completion: @escaping (Bool) -> Void) {
        
        if walkThroughPVC?.currentVC?.loggedInUserExist == true { return }
        
        
            guard let userName =  userName,
                let sponsorName = sponsorName,
                let sponsorPhoneNumber = sponsorPhone,
                let sponsorEmail = sponsorEmail,
                let aaStep = aaStep else { return }
            
        UserController.shared.createNewUserDetailsWith(userName: userName, sponsorName: sponsorName, sponserTelephoneNumber: sponsorPhoneNumber, sponsorEmail: sponsorEmail, aaStep: Int(aaStep) ) { (success) in
                if success {
                    print("\n🙏🏽 Creating new userDetails to CK successful\n")
                    DispatchQueue.main.async {
                        self.title = "Sucessflly Saved Example saveInfoToCloudKit func"
                    }
                    completion(true)
                } else {
                    print("Error Saving to Cloud Kit 💀")
                    completion(false)
                    return
                }
            }
        }
    }

