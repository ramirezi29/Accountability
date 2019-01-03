//
//  NotesTVCTableViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class NotesTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //Landing Pad
    var folder: Folder?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.selectedIndex = 2
        
        //Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        //Table view
        tableView.backgroundColor = .clear 
        
        //background Color
        view.addVerticalGradientLayer(topColor: UIColor(red: 55/255, green: 179/255, blue: 198/255, alpha: 1.0), bottomColor: UIColor(red: 154/255,green: 213/255, blue: 214/255, alpha: 1.0))
        
        // MARK: - Fetch
        guard let folder = folder else {
            print("\n'folder' in NotesTVC was Nil or something and the fetch func failed")
            return
        }
        
        NoteController.shared.fetchItems(folder: folder) { (note, _) in
            
            if note != nil {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    // stop animating spinner
                    // spinner view is hidding true
                }
                print("\n⛱ Successfully fetched folders from CK \n")
            } else {
                DispatchQueue.main.async {
                    // stop animating spinner
                    // spinner view is hidding true
                    let networkError = AlertController.presentAlertControllerWith(alertTitle: "Unable to Load Your Notes", alertMessage: "Check your internet connection", dismissActionTitle: "OK")
                    self.present(networkError, animated: true, completion: nil)
                }
                print("\n💀 Error fetching forders from CK\n")
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
     
    }
    
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NoteController.shared.notes.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.noteCellID, for: indexPath) as? NotesTVCell else {return UITableViewCell()}
        
        let note = NoteController.shared.notes[indexPath.row]
        
        cell.note = note
        
        return cell
    }
    
    //canEditRowAt
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let noteRecord = NoteController.shared.notes[indexPath.row]
            NoteController.shared.privateDB.delete(withRecordID: noteRecord.ckRecordID) { (_, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        //UI STUFF
                    }
                } else {
                    NoteController.shared.notes.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    //moveRowAt
     func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let note = NoteController.shared.notes[sourceIndexPath.row]
        
        NoteController.shared.notes.remove(at: sourceIndexPath.row)
        
        NoteController.shared.notes.insert(note, at: destinationIndexPath.row)
        
        // NOTE: - Need to Save the Re-ordering done to CK some how
    }
    
    //canMoveRowAt
      func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

     return true
     }
   
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? NoteDetailVC else { return }
        
        destinationVC.folder = folder
        
        if segue.identifier == NoteConstants.noteSegueID {
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let note = NoteController.shared.notes[indexPath.row]
            destinationVC.note = note
        }
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NotesTVC {
    
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
    }
}
