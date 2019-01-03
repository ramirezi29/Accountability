//
//  ColorCollection.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

enum MyColor {
    
    case powderBlue
    case hardBlue
    case offGrey
    case offWhite
    
}

extension MyColor {
    var value: UIColor {
        get {
            switch self {
            case .powderBlue:
                return UIColor(red: 229/255, green: 246/255, blue: 255/255, alpha: 1.0)
            case .hardBlue:
                return UIColor(red: 0/255, green: 164/255, blue: 252/255, alpha: 1.0)
            case .offGrey:
               return UIColor(red: 0.7765, green: 0.7765, blue: 0.7765, alpha: 1.0)
            case .offWhite:
               return UIColor(red: 0.9569, green: 0.9647, blue: 0.9686, alpha: 1.0)
            }
        }
    }
}
//MyColor.navigationBarBackgroundColor.value
