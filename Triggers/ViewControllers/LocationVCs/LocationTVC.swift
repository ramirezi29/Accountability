//
//  LocationTVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/21/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class LocationTVC: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Fetch from CK
        guard let user = user else {
            print(" guard let user = user else is nil or something")
            return
        }
        
        LocationController.shared.fetchItemsFor(user: user) { (location, error) in
            if location != nil {
                DispatchQueue.main.async {
                    //unhide activity indicator
                    //start animating activity indicator
                    //Activity Spinner Start
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    //hide activity indicator
                    //Activity Spinner Stop
                }
            } else {
                // Present UI ALert
                print("\n💀  Error fetcing location records from CK 💀n")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return LocationController.shared.locations.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationConstants.locationCellID, for: indexPath) as? LocationTVCell else {return UITableViewCell()}
        
        let location = LocationController.shared.locations[indexPath.row]
        
        cell.location = location
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let location = LocationController.shared.locations[sourceIndexPath.row]
        LocationController.shared.locations.remove(at: sourceIndexPath.row)
        LocationController.shared.locations.insert(location, at: destinationIndexPath.row)
        //Need to find how how to save the new order also in cloudKit
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
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
    
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
