//
//  LocationTVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/21/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class LocationTVC: UITableViewController {
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        
        //Navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        view.setGradientToTableView(tableView: tableView, UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        activityIndicatorView.backgroundColor = .clear
        
        //Activity Spinner
        self.activityIndicator.startAnimating()
        
        //Fetch from CK
        LocationController.shared.fetchItemsFor { (location, _) in
            if location != nil {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.hideStopActivityIndicator()
                    self.navigationController?.title = "Folders"
                }
                print("\nLocation Fetch was successful")
            } else {
                
                self.navigationController?.title = "No Folders Found"
                
                print("\n💀 Error fetcing location records from CK 💀")
                
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityIndicator.stopAnimating()
    }
    
    // MARK: - Table view data source
    override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return LocationController.shared.locations.count
    }
    
    
    override   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationConstants.locationCellID, for: indexPath) as? LocationTVCell else {return UITableViewCell()}
        
        let location = LocationController.shared.locations[indexPath.row]
        
        cell.location = location
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    
    //Future versions will include the ability to edit the TVC's row order
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let locationRecord = LocationController.shared.locations[indexPath.row]
            
            LocationController.shared.privateDB.delete(withRecordID: locationRecord.ckRecordID) { (_, error) in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        self.showStartActivityIndicator()
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
        
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func hideStopActivityIndicator() {
        self.activityIndicator.isHidden =  true
        self.activityIndicator.stopAnimating()
    }
    
    func showStartActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == LocationConstants.locationSegueID {
            
            guard let destinationVC = segue.destination as? LocationDetailVC,
                let idexPath = tableView.indexPathForSelectedRow else {return}
            
            let location = LocationController.shared.locations[idexPath.row]
            
            destinationVC.location = location
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}
