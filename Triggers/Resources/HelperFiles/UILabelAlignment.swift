//
//  UILabelAlignment.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/16/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

@IBDesignable class BottomAlignedLabel: UILabel {
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawText(in rect: CGRect) {
        
        guard text != nil else {
            return super.drawText(in: rect)
        }
        
        let height = self.sizeThatFits(rect.size).height
        let y = rect.origin.y + rect.height - height
        super.drawText(in: CGRect(x: 0, y: y, width: rect.width, height: height))
    }
}

