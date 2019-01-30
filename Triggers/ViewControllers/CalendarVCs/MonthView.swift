//
//  MonthView.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/1/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import UIKit

protocol MonthViewDelegate: class {
    func didChangeMonth(monthIndex: Int, year: Int)
}

class MonthView: UIView {
    var monthsArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var currentMonthIndex = 0
    var currentYear: Int = 0
    var delegate: MonthViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
        
        currentYear = Calendar.current.component(.year, from: Date())
        
        setupViews()
        
        leftButon.isEnabled = true
    }
    
    @objc func btnLeftRightAction(sender: UIButton) {
        if sender == rightButton {
            currentMonthIndex += 1
            if currentMonthIndex > 11 {
                currentMonthIndex = 0
                currentYear += 1
            }
        } else {
            currentMonthIndex -= 1
            if currentMonthIndex < 0 {
                currentMonthIndex = 11
                currentYear -= 1
            }
        }
        nameLabel.text="\(monthsArr[currentMonthIndex]) \(currentYear)"
        delegate?.didChangeMonth(monthIndex: currentMonthIndex, year: currentYear)
    }
    
    func setupViews() {
        self.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        nameLabel.text = "\(monthsArr[currentMonthIndex]) \(currentYear)"
        
        self.addSubview(rightButton)
        rightButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        rightButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        self.addSubview(leftButon)
        leftButon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftButon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftButon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        leftButon.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Default Month Year text"
        label.textColor = MyColor.offWhite.value
        label.textAlignment = .center
        label.font = MyFont.SFDisMed.withSize(size: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let rightButton: UIButton = {
        let button=UIButton()
        button.setTitle(">", for: .normal)
        button.setTitleColor(MyColor.offWhite.value, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnLeftRightAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    let leftButon: UIButton = {
        let button = UIButton()
        button.setTitle("<", for: .normal)
        button.setTitleColor(MyColor.offWhite.value, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnLeftRightAction(sender:)), for: .touchUpInside)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        return button
    }()
    
    //Test
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
