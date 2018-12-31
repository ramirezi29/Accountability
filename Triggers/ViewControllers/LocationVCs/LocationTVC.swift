//
//  LocationTVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/21/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class LocationTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var activityViewOutlet: UIView!
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    
    //landing pad
    var location: Location?
    
    //source of truth
    var user: User? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var loction: [Location] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView
        tableView.delegate = self
        tableView.dataSource = self 
        //Test Print
        print("🍁🍁Number of locations when view did load loaded: \(loction.count)🍁🍁")
        
        //Activity Spinner
        activityViewOutlet.backgroundColor = UIColor.clear
        activityIndicatorOutlet.startAnimating()
        
        //Background UI
        view.addVerticalGradientLayer(topColor: UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        //Fetch from CK
//        guard let user = user else {
//            print(" guard let user = user else is nil or something")
//            return
//        }
        
        LocationController.shared.fetchItemsFor { (_, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicatorOutlet.stopAnimating()
                self.activityViewOutlet.isHidden = true
                print("\nLocation Fetch was successful in the ViewDidLoad")
        }
}
        
//        LocationController.shared.fetchItemsFor(user: user) { (location, error) in
//            if location != nil {
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.activityIndicatorOutlet.stopAnimating()
//                    self.activityViewOutlet.isHidden = true
//                    print("\nLocation Fetch was successful")
//                }
//            } else {
//                DispatchQueue.main.async {
//
//                    self.activityIndicatorOutlet.stopAnimating()
//                    self.activityViewOutlet.isHidden = true
//                    // Present UI ALert
//                    print("\n💀 Error fetcing location records from CK 💀")
//                    return
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        print("View will appear just came up and the number of lcations are: \( self.loction.count)")
       
    }
    
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //TEST
//        tableView.isScrollEnabled = false
        
        
        return LocationController.shared.locations.count
        
        
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationConstants.locationCellID, for: indexPath) as? LocationTVCell else {return UITableViewCell()}
        
        let location = LocationController.shared.locations[indexPath.row]
        
        cell.location = location
        
        return cell
    }
    
    //Examine
//    override func viewDidLayoutSubviews() {
//        tableView.frame.size = tableView.contentSize
//    }
    
    
    
    // Override to support conditional editing of the table view.
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let locationRecord = LocationController.shared.locations[indexPath.row]
            
            LocationController.shared.privateDB.delete(withRecordID: locationRecord.ckRecordID) { (_, error) in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        //Preent UI Activity Spinner
                    }
                    
                } else {
                    LocationController.shared.locations.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Rearrange Cells
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let location = LocationController.shared.locations[sourceIndexPath.row]
        LocationController.shared.locations.remove(at: sourceIndexPath.row)
        LocationController.shared.locations.insert(location, at: destinationIndexPath.row)
        //Need to find how how to save the new order also in cloudKit
    }
    
    
    // Override to support conditional rearranging of the table view.
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LocationConstants.locationSegueID {
            guard let destinationVC = segue.destination as? LocationDetailVC,
                let idexPath = tableView.indexPathForSelectedRow else {return}
            let location = LocationController.shared.locations[idexPath.row]
            destinationVC.location = location
        }
    }
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .green
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
