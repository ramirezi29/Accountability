//
//  ButtonController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/8/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

/**
 A pre defined button with color and font type
 */
class IRButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        setTitleColor(MyColor.offWhite.value, for: .normal)
        backgroundColor = MyColor.buttonBlue.value
        titleLabel?.font = .boldSystemFont(ofSize: 17)
        layer.cornerRadius = frame.size.height / 4
    }
}

