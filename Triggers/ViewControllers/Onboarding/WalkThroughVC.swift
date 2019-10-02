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
    @IBOutlet weak var tintedBackgroundView: UIView!
    
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
        
        //Background
        tintedBackgroundView.backgroundColor = MyColor.powderBlue.value
        
        //Button
        nextButton.alpha = 0
        
        //Get the users info in order to check if an account already exists
        //⛺️  //⛺️
        loadUserDefaults()
        
        //In order to not present the onboarding screen
        //⛺️  //⛺️  //⛺️
        if disableOnBardingBool == true  {
            presentMainView()
            
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
    
    //⛺️  //⛺️  //⛺️
    func loadUserDefaults(){
        disableOnBardingBool = UserDefaults.standard.bool(forKey: disableOnboardingKey)
    }
    
    func updateUI() {
        if let index = walkThroughPVC?.currentIndex {
            print("\(String(describing: walkThroughPVC?.currentIndex))")
            
            switch index {
            case 4:
                print("case 4 was called")
                self.nextButton.alpha = 0
                
            case 5:
                self.nextButton.alpha = 0
                
            case 6:
                nextButton.setTitle("I Understand", for: .normal)
                UIView.animate(withDuration: 1.0, delay: 0.4, options: [.curveEaseOut], animations: {
                    
                    self.nextButton.alpha = 1.0
                }, completion: nil)
                
                print("Case 5")
                
            case 7:
                self.nextButton.alpha = 0
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
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if let index = walkThroughPVC?.currentIndex {
            
            switch index {
            case 0...5:
                walkThroughPVC?.forwardPage()
                
            case 6:
                walkThroughPVC?.currentVC?.inquirePermissions()
                walkThroughPVC?.forwardPage()
                walkThroughPVC?.currentVC?.inquirePermissions()
                print("case 5")
                
            case 7:
                walkThroughPVC?.forwardPage()
                
            case 8:
                if UserController.shared.loggedInUser == nil {
                    walkThroughPVC?.currentVC?.saveInfoToCloudKit(completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                //Future version animate the screen out
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


