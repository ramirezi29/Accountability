//
//  FolderTVC.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/31/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class FolderTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var folder: [Folder] = []
 
    
    @IBOutlet weak var newFolderButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cyles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        FolderController.shared.fetchItemsFor { (folder, error) in
            
            //show Spinner and Spin
            
            if folder != nil {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    // Activity Spinner Stop
                    // Hide Act Spinner View = .hide
                }
            } else {
                DispatchQueue.main.async {
                    // Activity Spinner Stop
                    // Hide Act Spinner View = .hide
                   let errorUIAlert = AlertController.presentAlertControllerWith(alertTitle: "Issue Getting Folders", alertMessage: "Check Your Internet Connection", dismissActionTitle: "OK")
                    
                    self.present(errorUIAlert, animated: true, completion: nil)
                    
                }
                print("\n🤫 Error Fetching Folders from CK\n")
                return
            }
        }
    }
    
    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
      tableView.reloadData()
        print("View will appear just came up and the number of folders are: \( self.folder.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
          tableView.isEditing = false
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FolderController.shared.folders.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.folderCellID, for: indexPath)
        
        let folder = FolderController.shared.folders[indexPath.row]
        
        cell.textLabel?.text = folder.folderTitle
        cell.detailTextLabel?.text = "\(folder.notes.count)"
        return cell
        
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let folderRecord = FolderController.shared.folders[indexPath.row]
            
            FolderController.shared.privateDB.delete(withRecordID: folderRecord.ckRecordID) { (_, error) in
                if error != nil {
                    
                    DispatchQueue.main.async {
                        //UI Stuff Activity Spinner
                    }
                } else {
                    FolderController.shared.folders.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
        
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let folder = FolderController.shared.folders[sourceIndexPath.row]
        
        FolderController.shared.folders.remove(at: sourceIndexPath.row)
        
        FolderController.shared.folders.insert(folder, at: destinationIndexPath.row)
        
        // NOTE: - Save the Order
        //make sure it saves order to clout kit
    }
    
    
     func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     return true
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
    
    @IBAction func editButtonTapped(_ sender: Any) {
        print("Edit Tapped")
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped(_:)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonTapped(_:)))
        }
    }

    
    @IBAction func newFolderButtonTapped(_ sender: Any) {
        
        addFolderAlert()
    }
}
extension FolderTVC {
    
    func addFolderAlert() {
        
        let myCustomerAlert = AlertController.presentAlertControllerWith(alertTitle: "New Folder", alertMessage: "Enter a name for this Folder", dismissActionTitle: "Cancel")
        
        myCustomerAlert.addTextField { (folderName) in
            folderName.placeholder = "Name"
            //Special Font?
        }
        
        let saveFolderName = UIAlertAction(title: "Save", style: .default) { (_) in
            
            guard let folderNameTextField = myCustomerAlert.textFields?.first?.text, !folderNameTextField.isEmpty else {return}
            FolderController.shared.createNewFolder(folderTitle: folderNameTextField) { (success) in
                if success {
                    
                    DispatchQueue.main.async {
                        FolderController.shared.fetchItemsFor(completion: { (_, _) in
                        })
                        self.tableView.reloadData()
                    }
                }
            }
        }

        myCustomerAlert.addAction(saveFolderName)
        
        self.present(myCustomerAlert, animated: true, completion: nil)
    }
}

extension FolderTVC {
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.backgroundColor = .clear 
        cell.backgroundColor = .clear
    }
}
