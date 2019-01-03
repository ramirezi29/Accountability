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
        
        //test
       
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        loadViewBackGround()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
      tableView.reloadData()

        print("View will appear just came up and the number of folders are: \( self.folder.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
          tableView.isEditing = false
    }
    
    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FolderController.shared.folders.count
    }
    
    //Cell for row at
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.folderCellID, for: indexPath)
        
        let folder = FolderController.shared.folders[indexPath.row]
        
        cell.textLabel?.text = folder.folderTitle
        cell.detailTextLabel?.text = "\(folder.notes.count)"
        return cell
        
    }
    
    // Can Edit
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
                    print("\nError Editing the Folder Record\n")
                    let editingFolderError = AlertController.presentAlertControllerWith(alertTitle: "Error Updating Folder", alertMessage: "Check Your Internet Connection", dismissActionTitle: "OK")
                    self.present(editingFolderError, animated: true, completion: nil)
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
            
            print("\n\n🚀 the prepare for segue func is being called and this is the folder indexPath.row: \(FolderController.shared.folders[indexPath.row])\n\n")
            
            // ASK - It Breaks here at times
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
        
        var folderNameTextField: UITextField?
        
        let myCustomerAlert = AlertController.presentAlertControllerWith(alertTitle: "New Folder", alertMessage: "Enter a name for this Folder", dismissActionTitle: "Cancel")
        
        myCustomerAlert.addTextField { (folderName) in
            folderName.placeholder = "Name"
            folderNameTextField = folderName
            //Special Font?
        }
        
       
        let saveFolderName = UIAlertAction(title: "Save", style: .default) { (_) in
            
//            guard let folderNameTextField = myCustomerAlert.textFields?.first?.text, !folderNameTextField.isEmpty else {return}
            guard let name = folderNameTextField?.text, !name.isEmpty else {return}
            
            // MARK: - Create New Folder
            FolderController.shared.createNewFolder(folderTitle: name) { (success) in
                if success {
                    
                    // MARK: - Fetch Folder Items
//                    FolderController.shared.fetchItemsFor(completion: { (folder, error) in
                    
//                        FolderController.shared.fetchItemsFor(completion: { (folders, _) in
//                        })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
//                        if folder != nil {
                    
                
//                            }
//                            print("\nSuccessfuly fetched folders\n")
//                        } else {
//                            print("\nThere was an error saving the folder's name with the UIAlert")
//                            let folderErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Updating the Folders", alertMessage: "Please Try Again, Check your network connection", dismissActionTitle: "OK")
//                            DispatchQueue.main.async {
//                                self.present(folderErrorNotif, animated: true, completion: nil)
//                            }
//                            return
//                        }
//                    })
          
                } else {
                    print("There was an error creating the new folder record")
                    DispatchQueue.main.async {
                        let folderSaveErrorNotif = AlertController.presentAlertControllerWith(alertTitle: "Error Creating Folder", alertMessage: "Please Try Again, Check your network connection", dismissActionTitle: "OK")
                        self.present(folderSaveErrorNotif, animated: true, completion: nil)
                    }
                    return
                }
            }
        }

        myCustomerAlert.addAction(saveFolderName)
        
        self.present(myCustomerAlert, animated: true, completion: nil)
    }
}

extension FolderTVC {
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
    }
}

extension FolderTVC {
    
    func loadViewBackGround() {
          view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
    }
}
