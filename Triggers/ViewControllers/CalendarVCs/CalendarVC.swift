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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var themeButton: UIBarButtonItem!
    
    @IBAction func themeButtonTapped(_ sender: UIBarButtonItem) {
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
    
    var theme = MyTheme.dark
    var user: User?
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        //        self.title = "My Calender"
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        view.addSubview(calenderView)
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive = true
        calenderView.heightAnchor.constraint(equalToConstant: 365).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
//            return
//        }
//        
//        // Will take you to the onboarding storyboard if user defaults hasnt been hit above
//        let storyboard = UIStoryboard(name: "WalkThroughOnBoarding", bundle: nil)
//        
//        if let walkThroughVC = storyboard.instantiateViewController(withIdentifier: "WalkThroughVC") as? WalkThroughVC {
//            present(walkThroughVC, animated: true, completion: nil)
//        }
     
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    let calenderView: CalenderView = {
        let v = CalenderView(theme: MyTheme.dark)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        print("Share Button Tapped")
        
        guard let user = user else {
            print("Calendar view no user found, its nill")
            return
            
        }
        
//        let share = CKShare(rootRecord: user.ck)
//        share[CKShareTitleKey] = "Some title" as CKRecordValue?share[CKShareTypeKey] = "Some type" as CKRecordValue?
//        let sharingController = UICloudSharingController
//        (preparationHandler: {(UICloudSharingController, handler:
//            @escaping (CKShare?, CKContainer?, Error?) -> Void) in
//            let modifyOp = CKModifyRecordsOperation(recordsToSave:
//                [employeeRecord, share], recordIDsToDelete: nil)
//            modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
//                error) in
//                handler(share, CKContainer.default(), error)
//            }
//            CKContainer.default().privateCloudDatabase.add(modifyOp)
//        })
//        sharingController.availablePermissions = [.allowReadWrite,
//                                                  .allowPrivate]
//        sharingController.delegate = self
//        self.present(sharingController, animated:true, completion:nil)
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

