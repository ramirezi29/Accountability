//
//  HomeViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var sponseeNameLabel: UILabel!
    @IBOutlet weak var sponsorNameButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var aaStepButton: UIButton!
    
    //Landing pad
    var sponseeName: String?
    var sponsorName: String?
    var aaStep: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
             updateViews()
        
     

         view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0) ,
                                    bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
    }
    
    func updateViews() {
        guard let unwrappedSponseeName = sponseeName,
        let unswrappedSponsorName = sponsorName else {return}
        
//        let unwrappedAaStep = aaStep
        
        sponseeNameLabel.text = unwrappedSponseeName
        sponsorNameButton.setTitle("\(unswrappedSponsorName)", for: .normal)
//        aaStepButton.setTitle("\(unwrappedAaStep)", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkThroughVC = storyboard.instantiateViewController(withIdentifier: "WalkThroughVC") as? WalkThroughVC {
            present(walkThroughVC, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func locationButtonTapped(_ sender: Any) {
    }
    
    @IBAction func aaStepButtonTapped(_ sender: Any) {
    }
    
}
