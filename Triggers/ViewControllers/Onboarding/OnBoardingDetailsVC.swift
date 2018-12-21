//
//  OnBoardingDetailsViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class OnBoardingDetailsVC: UIViewController {

    @IBOutlet weak var sponsseeNameTextField: UITextField!
    
    @IBOutlet weak var sponsorNameTextField: UITextField!
    
    @IBOutlet weak var aaStepTextField: UITextField!
    
    @IBOutlet weak var saveButtonTapped: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let sponseeName = sponsseeNameTextField.text,
        let sponsorName = sponsorNameTextField.text
//        let aaStep = aaStepTextField.text
        else {return}
        
        guard let destinationVC = segue.destination as? HomeViewController else {return}
        
//        destinationVC.sponseeName = sponseeName
//        destinationVC.sponsorName = sponsorName
//        destinationVC.aaStep = aaStep
        
    }
   

}
