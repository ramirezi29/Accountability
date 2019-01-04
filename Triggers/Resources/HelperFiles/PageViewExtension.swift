//
//  PageViewExtension.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/3/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

extension UIPageViewController {
    
    func enableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = true
            }
        }
    }
    
    func disableSwipeGesture() {
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
}
