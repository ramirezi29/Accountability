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
    
    var pageHeadings = ["Welcome", "Statistics", "What is Geo-Fence", "How do we track your device", "Why We track your device", "On Boarding User Details"]
    let pageImages = ["cloudImage", "cloudImage", "cloudImage", "cloudImage", "cloudImage", "cloudImage", "cloudImage"] // can add more
    let pageSubHeadings = ["Welcome", "Statistics", "What is Geo-Fence", "How do we track your device", "Why We track your device", "On Boarding User Details"]
    
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
        var index = (viewController as? WalkThroughContentVC)?.index ?? 1
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
        if index < 0 || index >= pageHeadings.count
        {
            return nil
        }
        //Storyboard ID for the walk through screen. ID used as a ref to create the storyboard instance
        let storyboard = UIStoryboard(name: "WalkThroughOnBoarding", bundle: nil)
        //
        if let walkthroughVC = storyboard.instantiateViewController(withIdentifier: "WalkThroughContentVC") as? WalkThroughContentVC {
            walkthroughVC.imageFile = pageImages[index]
            walkthroughVC.headLine = pageHeadings[index]
            walkthroughVC.subHeadLine = pageSubHeadings[index]
            walkthroughVC.index = index
            
            return walkthroughVC
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

