//
//  OnboardingPVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class WalkThroughPVC: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageHeadings = ["Welcome", "Statistics", "What is Geo-Fence", "How do we track your device", "Why We track your device", "On Boarding User Details"]
    let pageImages = ["cloudImage"] // can add more
    let pageSubHeadings = ["Welcome", "Statistics", "What is Geo-Fence", "How do we track your device", "Why We track your device", "On Boarding User Details"]
    
    var currentIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the data source to itself
        dataSource = self
        
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
        var index = (viewController as? WalkThroughContentVC)?.index ?? 1
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
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
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
}

