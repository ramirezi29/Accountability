//
//  FontController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/8/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

enum MyFont: String {
    case SFReg = "SFProText-Regular"
    case SFMed = "SFProText-Medium"
    case SFBold = "SFProText-Bold"
    case SFDisReg = "SFProDisplay-Regular"
    case SFDisMed = "SFProDisplay-Medium"
 
    
    func withSize(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}

