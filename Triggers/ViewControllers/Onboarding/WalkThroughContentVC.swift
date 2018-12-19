//
//  WalkThroughVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class WalkThroughContentVC: UIViewController {

    
    @IBOutlet var headLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subHeadLineLabel: UILabel! {
        didSet {
            headLineLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    
    var index = 0
    var headLine = ""
    var subHeadLine = ""
    var imageFile = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        headLineLabel.text = headLine
        subHeadLineLabel.text = subHeadLine
        contentImageView.image  = UIImage(named: imageFile)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
