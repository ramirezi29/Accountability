//
//  ColorGradientExtension.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
extension UIView {
    
    
    /*
     ----------------------------------------------------------------------
     Adds a vertical gradient layer with two **UIColors** to the **UIView**.
     - Parameter topColor: The top **UIColor**.
     - Parameter bottomColor: The bottom **UIColor**.
     call the following code in the view did load or will
     
     view.addVerticalGradientLayer(topColor: .clear , bottomColor: .blue)
     ----------------------------------------------------------------------
     */
    // bonds is the size of the screen
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
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



//func setGradientToTableView(tableView: UITableView, _ topColor:UIColor, _ bottomColor:UIColor) {
//
//    let gradientBackgroundColors = [topColor.CGColor, bottomColor.CGColor]
//    let gradientLocations = [0.0,1.0]
//
//    let gradientLayer = CAGradientLayer()
//    gradientLayer.colors = gradientBackgroundColors
//    gradientLayer.locations = gradientLocations
//
//    gradientLayer.frame = tableView.bounds
//    let backgroundView = UIView(frame: tableView.bounds)
//    backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
//    tableView.backgroundView = backgroundView
//}
//}
