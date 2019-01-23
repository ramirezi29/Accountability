//
//  NoteController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/19/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class NoteController {
    static let shared = NoteController()
    
    private init() {}
    
    var notes =  [Note]()
    
    var usersLocationRefrence: CKRecord.ID?
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = ([Note]?, NetworkingError?) -> Void
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    func fetchItems(folder: Folder, completion: @escaping fetchCompletion) {
        
        //Test Print
        print("Random info From folder fetch: user: \(folder)")
        
        let folderParentID = folder.ckRecordID
        
        let predicate = NSPredicate(format: "\(NoteConstants.folderReferenceKey) == %@", folderParentID)
        
        let query = CKQuery(recordType: NoteConstants.NoteTypeKey, predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: NoteConstants.timeStampKey, ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("\n\n🚀 There was an error with fetching the records in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(nil, .forwardedError(error))
                return
            }
            // Make sure we have records
            guard let records = records else {
                completion(nil, .invalidData("\nINvalid Data\n"))
                return
            }
            // Gather items into array, replace source of truth, call completion
            let fetchedNotes = records.compactMap{ Note(ckRecord: $0) }
            self.notes = fetchedNotes
            completion(fetchedNotes, nil)
        }
    }
    
    // MARK: - Save
    func saveToCloudKit(notes: Note, completion: @escaping boolVoidCompletion) {
        
        let notesRecord = CKRecord(note: notes)
        
        privateDB.save(notesRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newNote = Note(ckRecord: record) else {
                
                print("\n💀 No Record came back from CloudKit\n")
                
                completion(false)
                return
            }
            
            self.notes.append(newNote)
            completion(true)
        }
    }
    
    // MARK: - Create
    func createNewNoteWith(title: String, textBody: String, folder: Folder, completion: @escaping boolVoidCompletion) {
        
        let newNote = Note(title: title, textBody: textBody, folderReference: CKRecord.Reference(recordID: folder.ckRecordID, action: .deleteSelf))
        
        saveToCloudKit(notes: newNote) { (success) in
            if success {
                print("\nSuccessfully created record\n")
                FolderController.shared.add(note: newNote, to: folder)
                completion(true)
                
            } else {
                
                print("\nError Creating Record\n")
                
                completion(false)
                
                //for test purposes fatal error
//                fatalError("\nFatal Error , error creating record\n")
            }
        }
    }
    
    // MARK: - Update
    func updateNote(note: Note, title: String, textBody: String, completion: @escaping boolVoidCompletion) {
        note.title = title
        note.textBody = textBody
        
        let record = CKRecord(note: note)
        
        let operration = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operration.savePolicy = .changedKeys
        operration.queuePriority = .high
        operration.qualityOfService = .userInteractive
        operration.completionBlock = {
            
            completion(true)
        }
        privateDB.add(operration)
    }
}
