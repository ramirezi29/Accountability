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
    func fetchItems(notes: Note, completion: @escaping fetchCompletion) {
        
        // Match item records whose owningList(newsletter) field points to the specified list record (instance of Newsletter)
         let notesParentID = notes.ckRecordID
        let userNoteReference = CKRecord.Reference(recordID: notesParentID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(NoteConstants.userNoteReferenceKey) == %@", userNoteReference)
        
        /*
         add this to the location controller
         let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userDetailsReference)
         */
        
        // Create the query object, and set the sort order.
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
    func createNewNoteWith(note: Note, title: String, textBody: String, userNoteReference: CKRecord.Reference, completion: @escaping boolVoidCompletion) {


        // Note sure if i needed the CKRecord.ID version
         let noteRecordID = note.ckRecordID
        let userNoteReference = CKRecord.Reference(recordID: noteRecordID, action: .deleteSelf)
        //Need to fix this line below
        let newNote = Note(title: title, textBody: textBody, userNoteReference: userNoteReference)
        
        // ASK: - Not Sure if this userRecord instance is needed
        // create a record so that it can be saved
//        let userRecord = CKRecord(note: <#T##Note#>)
        saveToCloudKit(notes: newNote) { (success) in
            if success {
                print("\nSuccessfully created record\n")
                completion(true)
            } else {
                completion(false)
                print("\nError Creating Record\n")
                //for test purposes fatal error
                fatalError("\nFatal Error , error creating record\n")
            }
        }

    }

    // MARK: - Update
    //ASK: - DO i need to update a ckRefrence
    func updateNote(note: Note, title: String, textBody: String, completion: @escaping boolVoidCompletion) {
       note.title = title
        note.textBody = textBody

        let record = CKRecord(note: note)

        //Note sure why Nil ??
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
