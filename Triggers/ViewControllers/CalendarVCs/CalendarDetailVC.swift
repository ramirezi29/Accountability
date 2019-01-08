//
//  CalendarDetailVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class CalendarDetailVC: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var dateLabel: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var locationAddressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0) ,
                                      bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
