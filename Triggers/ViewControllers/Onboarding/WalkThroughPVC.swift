//
//  OnboardingPVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//



import UIKit

protocol WalkthroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkThroughPVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
     weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
    var currentVC: WalkThroughContentVC?

    var pageHeadings = ["Triggers",
                        
                        "Addiction recovery is difficult",
                        
                        "Triggers provides an additional layer of support",
                        
                        "Don't feel isolated",
                        
                        "Contact Information",
                        
                        "Triggers is there to help",
                        
                        "Allow Location Services",
                        
                        "Ready? Let's get to work"]
    
    
    
    var pageSubHeadings = ["One Step Closer To Elimenating Your Triggers",
                           
                           "85% of individuals will relapse at one point during their journey of recover \n\n(wwww.addiction.gov)",
                           
                           "\n\nAs your companion, we can assist you stay away from locations that may cause a trigger to relapse",
                           
                           "Provide Triggers with the contact information of your accountability partner or sponsor",
                           
                           "Enter at least one field",
                           
                           "We are with you ever Step of the way of your journey. \nAllow location services in order to better serve you",
                           
                           "Add another layer of accountability and support to your addiction recovery journey",
                           
                           ""]

    
    var pageImages = ["LocationLogo", "ambulance", "handshake", "friendship", "paperplane", "map", "gps", "landscape"] 
    
    
    var currentIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source to itself
        dataSource = self
        delegate = self
        
        // create first walk through screen
        if let startingViewController = walkThroughContentController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
}



extension WalkThroughPVC {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkThroughContentVC).index
        index -= 1
        return walkThroughContentController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkThroughContentVC).index
        index += 1
        return walkThroughContentController(at: index)
    }
    
    
    
    
    // page index is in the paramaters, if zero it will create the first onboarding screen
    func walkThroughContentController(at index: Int) -> WalkThroughContentVC? {
        // validation to check
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        //Storyboard ID for the walk through screen. ID used as a ref to create the storyboard instance
        let storyboard = UIStoryboard(name: "WalkThroughOnBoarding", bundle: nil)
        //
        if let pageContentVC = storyboard.instantiateViewController(withIdentifier: "WalkThroughContentVC") as? WalkThroughContentVC {
            pageContentVC.imageFile = pageImages[index]
            pageContentVC.headLine = pageHeadings[index]
            pageContentVC.subHeadLine = pageSubHeadings[index]
            pageContentVC.index = index
            self.currentVC = pageContentVC
            return pageContentVC
        }
        return nil
    }
    
    func forwardPage() {
        currentIndex += 1
        if let nextViewController = walkThroughContentController(at: currentIndex) {
            setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Page View Controller delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? WalkThroughContentVC {
                currentIndex = contentViewController.index
                
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
}

