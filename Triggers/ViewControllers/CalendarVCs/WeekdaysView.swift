//
//  WeekdaysView.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/1/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

class WeekdaysView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        setupViews()
    }
    
    func setupViews() {
        addSubview(myStackView)
        myStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        myStackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        myStackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        myStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        var daysArray = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        for i in 0..<7 {
            let dayLabel = UILabel()
            dayLabel.text = daysArray[i]
            dayLabel.textAlignment = .center
            dayLabel.textColor = MyColor.offWhite.value
            myStackView.addArrangedSubview(dayLabel)
        }
    }
    
    let myStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //Test
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

