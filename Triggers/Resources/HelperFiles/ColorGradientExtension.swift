//
//  ColorGradientExtension.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     An exention on UIView that renders a gradiant on a UIViewController
     
     - Parameter topColor: Top color for gradiant
     - Parameter bottomColor: Bottom color for gradiant
     */
    func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 20.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 20)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    /**
     An exention on UIView that renders a gradiant on a UITableView
     
     - Parameter topColor: Top color for gradiant
     - Parameter bottomColor: Bottom color for gradiant
     */
    func setGradientToTableView(tableView: UITableView, _ topColor:UIColor, _ bottomColor:UIColor) {
        
        let gradientBackgroundColors = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientBackgroundColors
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = tableView.bounds
        
        let backgroundView = UIView(frame: tableView.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        tableView.backgroundView = backgroundView
    }
}
