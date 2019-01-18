//
//  NotesTVCTableViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class NotesTVC: UITableViewController {

    //Landing Pad
    var folder: Folder?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.setGradientToTableView(tableView: tableView, UIColor(red:55/255, green: 179/255, blue: 198/255, alpha: 1.0), UIColor(red: 154/255, green: 213/255, blue: 214/255, alpha: 1.0))
        
        //Delegates
        tableView.delegate = self
        tableView.dataSource = self

        
        // MARK: - Fetch
        guard let folder = folder else  {
            print("\n'folder' in NotesTVC was Nil or something and the fetch func failed")
            
            return
        }
        print("The folder that was selected was 🐠\(folder.folderTitle) and it has \(folder.notes.count) note(s) inside of it, according to iCloud")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
     
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder?.notes.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.noteCellID, for: indexPath) 
        
        //Notes
//        let note = NoteController.shared.notes[indexPath.row]
        
        guard let songInFolder = folder?.notes[indexPath.row] else {return UITableViewCell()}
        
        
        //Folders, just to see if this is the correct one that will get rid of the random bug
//        let note = folder?.notes[indexPath.row]
        
        cell.textLabel?.text = songInFolder.title
        cell.detailTextLabel?.text = songInFolder.timeStampAsString
        
        return cell
    }
    
    //canEditRowAt
   override  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
   override  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let note = NoteController.shared.notes[sourceIndexPath.row]
        
        NoteController.shared.notes.remove(at: sourceIndexPath.row)
        
        NoteController.shared.notes.insert(note, at: destinationIndexPath.row)
        
        // NOTE: - Need to Save the Re-ordering done to CK some how
    }
    
    //canMoveRowAt
    override  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {

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

}

extension NotesTVC {
    
   override  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
    }
}
