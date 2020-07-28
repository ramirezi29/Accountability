//
//  FolderTVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/31/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class FolderTVC: UITableViewController {
    
    
    @IBOutlet weak var newFolderButton: UIBarButtonItem!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var folder: [Folder] = []
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.startAnimating()
        setUpNavUI()
        fetchCKFolders()
        
        view.setGradientToTableView(tableView: tableView, UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        activityView.backgroundColor = .clear
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.main.async {
            self.hideStopActivityIndicator()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let folderCount = FolderController.shared.folders.count
        
        return folderCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.folderCellID, for: indexPath)
        let folder = FolderController.shared.folders[indexPath.row]
        
        cell.textLabel?.text = folder.folderTitle
        cell.detailTextLabel?.text = "\(folder.notes.count)"
        cell.textLabel?.textColor = ColorPallet.offWhite.value
        cell.detailTextLabel?.textColor = ColorPallet.offWhite.value
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let folderRecord = FolderController.shared.folders[indexPath.row]
            
            FolderController.shared.privateDB.delete(withRecordID: folderRecord.ckRecordID) { (ckRecordID, _) in
                if (ckRecordID != nil) {
                    FolderController.shared.folders.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.reloadData()
                    }
                } else {
                    let editingFolderError = AlertController.presentAlertControllerWith(alertTitle: "Error Updating Folder", alertMessage: "Check Your Internet Connection and ensure you are signed into your iCloud account on your device", dismissActionTitle: "OK")
                    DispatchQueue.main.async {
                        self.present(editingFolderError, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let folder = FolderController.shared.folders[sourceIndexPath.row]
        
        FolderController.shared.folders.remove(at: sourceIndexPath.row)
        FolderController.shared.folders.insert(folder, at: destinationIndexPath.row)
        // NOTE: - Save the Order
        //make sure it saves order to clout kit
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.tableFooterView = UIView()
        cell.backgroundColor = .clear
    }
    
    func setUpNavUI() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Activity Indicators
    func hideStopActivityIndicator() {
        self.activityIndicator.isHidden =  true
        self.activityIndicator.stopAnimating()
    }
    
    func showStartActivityIndicator() {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }
    
    func addFolderAlert() {
        var folderNameTextField: UITextField?
        
        let myCustomerAlert = AlertController.presentAlertControllerWith(alertTitle: "New Folder", alertMessage: "Enter a name for this folder", dismissActionTitle: "Cancel")
        
        myCustomerAlert.addTextField { (folderName) in
            folderName.placeholder = "Enter Name"
            folderNameTextField = folderName
        }
        
        let saveFolderName = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let name = folderNameTextField?.text, !name.isEmpty else {return}
            
            // MARK: - Create New Folder
            FolderController.shared.createNewFolder(folderTitle: name) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        let folderSaveErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Creating Folder", alertMessage: "Check your internet connection and ensure that you are signed into your iCloud account", dismissActionTitle: "OK")
                        self.present(folderSaveErrorNotif, animated: true, completion: nil)
                    }
                    return
                }
            }
        }
        myCustomerAlert.addAction(saveFolderName)
        self.present(myCustomerAlert, animated: true, completion: nil)
    }
    
    // MARK: - Fetch Folders
    func fetchCKFolders() {
        //Fetch Folders from CK
        FolderController.shared.fetchItemsFor { (folder, error) in
            if folder != nil {
                folder?.forEach({ (folder) in
                    NoteController.shared.fetchItems(folder: folder) { (note, _) in
                        if note != nil {
                            folder.notes = note!
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.hideStopActivityIndicator()
                            }
                        } else {
                            let networkError = AlertController.presentAlertControllerWith(alertTitle: "Unable to load notes", alertMessage: "Check your internet connection and ensure that you are signed into iCloud", dismissActionTitle: "OK")
                            DispatchQueue.main.async {
                                self.present(networkError, animated: true, completion: nil)
                            }
                            return
                        }
                    }
                })
                
                DispatchQueue.main.async {
                    self.hideStopActivityIndicator()
                }
            } else {
                DispatchQueue.main.async {
                    //UI Element will go here in future versions
                }
                return
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NoteConstants.folderSegueID {
            
            guard let destinationVC = segue.destination as? NotesTVC,
                let indexPath = tableView.indexPathForSelectedRow else {return}
            
            let folder = FolderController.shared.folders[indexPath.row]
            destinationVC.folder = folder
        }
    }
    
    @IBAction func newFolderButtonTapped(_ sender: Any) {
        addFolderAlert()
    }
}
