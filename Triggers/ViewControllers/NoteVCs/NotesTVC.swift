//
//  NotesTVCTableViewController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/18/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit

class NotesTVC: UITableViewController {
    
    var folder: Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientToTableView(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpFolder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func setUpFolder() {
        guard let folder = folder else  { return }
              title = "\(folder.folderTitle)"
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder?.notes.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteConstants.noteCellID, for: indexPath)
        guard let songInFolder = folder?.notes[indexPath.row] else {return UITableViewCell()}
        cell.textLabel?.text = songInFolder.title
        cell.detailTextLabel?.text = songInFolder.timeStampAsString
        cell.textLabel?.textColor = ColorPallet.offWhite.value
        cell.detailTextLabel?.textColor = ColorPallet.offWhite.value
        return cell
    }
    
    //canEditRowAt
    override  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            guard let folder = folder else {return}
            
            let noteRecordInFolder = folder.notes[indexPath.row]
            NoteController.shared.privateDB.delete(withRecordID: noteRecordInFolder.ckRecordID) { (_, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        //Future version will include a UI element
                    }
                } else {
                    self.folder?.notes.remove(at: indexPath.row)
                    //NoteController.shared.notes.remove(at: indexPath.row)
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
    }
    
    override  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? NoteDetailVC else {
            return
        }
        destinationVC.folder = folder
        
        if segue.identifier == NoteConstants.noteSegueID {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let noteInFolder = folder?.notes[indexPath.row]
            destinationVC.note = noteInFolder
        }
    }
}
