//
//  WalkThroughVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class WalkThroughVC: UIViewController, WalkthroughPageViewControllerDelegate {
    
    // MARK: - Oulets
    @IBOutlet var bossViewOutlet: UIView!
    @IBOutlet weak var buttomViewOutlet: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 10.0
            nextButton.layer.masksToBounds = true
            nextButton.setTitle("Next", for: .normal)
            nextButton.backgroundColor = MyColor.hardBlue.value
            nextButton.setTitleColor(MyColor.offWhite.value, for: .normal)
        }
    }

    @IBOutlet var skipButton: UIButton!
    
    var walkThroughPVC: WalkThroughPVC?
    var disableOnBardingBool = false
    var disableOnboardingKey = "disableOnboardingKey"
    var walkThroughCVC: WalkThroughContentVC?
    var hasSeenPermissions = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // user defualts
        loadUserDefaults()
        
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
        pageControl.numberOfPages = 8

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
//            case 0...4:
//
//                print("The Walk through PVC is somewhere in between case 0 - 5, and the current index is, \(index)")
//                self.nextButton.isEnabled = true
            case 4:
                 nextButton.setTitle("Next", for: .normal)
            case 5:
                
                if hasSeenPermissions == false {
                    hasSeenPermissions = true
                 nextButton.setTitle("I Understand", for: .normal)
                } else {
                    nextButton.setTitle("Next", for: .normal)
                }
            case 6:
                UIView.animate(withDuration: 0.9, delay: 0.1, options: [.curveEaseOut], animations: {
                    self.nextButton.backgroundColor =  MyColor.hardBlue.value
                    
                }, completion: nil)
                
                  nextButton.setTitle("Next", for: .normal)
                
                UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
                    self.nextButton.alpha = 1.0
                }, completion: nil)
                
                
//                Uncomment for later version if you want to show the nextButton on the walk through VC starting from index [0]


            case 7:
                self.nextButton.alpha = 0.3
            print("the Walk Through PVC hit the last case which is 6 and the index is \(index)")
                nextButton.isEnabled = true
                  nextButton.isHidden = false

                  UIView.animate(withDuration: 1.0, delay: 0.4, options: [.curveEaseOut], animations: {
                    self.nextButton.backgroundColor =  MyColor.softGreen.value
                    self.nextButton.alpha = 1.0
                  }, completion: nil)

                nextButton.setTitle("GET STARTED", for: .normal)
            default: break
                
            }
            pageControl.currentPage = index
        }
    }
    
    func presentMainView() {
        let calendarStoryboard = UIStoryboard(name: StoryboardConstants.mainStoryboard, bundle: nil).instantiateInitialViewController()!
        
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
            case 0...4:
                walkThroughPVC?.forwardPage()
                
                nextButton.setTitle("Next", for: .normal)
                
            case 5:
                walkThroughPVC?.forwardPage()
              
            
            case 6:
                walkThroughPVC?.forwardPage()
                nextButton.setTitle("Next", for: .normal)
            case 7:
                
                // check if already been viewed
//                if disableOnBardingBool == false {
//                    disableOnBardingBool = true
//
                     UserDefaults.standard.set(true, forKey: UserDefaultConstants.isOnboardedKey)
//
//                    // NOTE: - This probably shouldnt be here check
//                    dismiss(animated: true, completion: nil)
//
                    presentMainView()
//                }
              
//
//                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                
                // Needed only if they get to the Home VC wihtout first going thorugh the onboarding
//                dismiss(animated: true, completion: nil)
                
                
                // Segue programatically to home view controller
//                presentMainView()
                
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
