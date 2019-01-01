//
//  CalendarVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit
import CloudKit

enum MyTheme {
    case light
    case dark
}

class CalendarVC: UIViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var theme = MyTheme.dark
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
        self.title = "My Calender"
        self.navigationController?.navigationBar.isTranslucent=false
        self.view.backgroundColor = Style.bgColor
        
        view.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive=true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive=true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive=true
        calenderView.heightAnchor.constraint(equalToConstant: 365).isActive=true
        
        let rightBarBtn = UIBarButtonItem(title: "Light", style: .plain, target: self, action: #selector(rightBarBtnAction))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func rightBarBtnAction(sender: UIBarButtonItem) {
        if theme == .dark {
            sender.title = "Dark"
            theme = .light
            Style.themeLight()
        } else {
            sender.title = "Light"
            theme = .dark
            Style.themeDark()
        }
        self.view.backgroundColor=Style.bgColor
        calenderView.changeTheme()
    }
    
    let calenderView: CalenderView = {
        let v = CalenderView(theme: MyTheme.dark)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    @IBAction func shareButtonTapped(_ sender: Any) {
      print("Share Button Tapped")
    }
}

extension CalendarVC: UICloudSharingControllerDelegate {
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("EXAMPLE")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        print("EXAMPLE")
        return "Sample Title"
    }
    
    
    
    
}


/*
 
 /        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0) ,
 //                                      bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
 
 
 */
