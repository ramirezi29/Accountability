//
//  FolderController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/29/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class FolderController {
    
    static let shared = FolderController()
    
    private init() {}
    
    var folders = [Folder]()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = ([Folder]?, NetworkingError?) -> Void
    
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    func fetchItemsFor(user: User? = UserController.shared.loggedInUser, completion: @escaping fetchCompletion) {
        
        //Test Print
        print("☃️ WHen the page was loaded and the Folder fetch func ran, there were \(folders.count) folders fetched")
        
        guard let user = user else {
            completion(nil, .invalidData("Invalid user"))
            return
        }
        
        //Test Print
        print("Random info From folder fetch: user: \(user)")
        
        guard let userParentID = user.ckRecordID else {
            completion(nil, .invalidData("Invalid User Parent ID"))
            return
        }
        
        let predicate = NSPredicate(format: "\(FolderConstants.userFolderReferenceKey) == %@", userParentID)
        
        let query = CKQuery(recordType: FolderConstants.FolderTypeKey, predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: FolderConstants.timeStampKey, ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("\n\n🚀 There was an error with fetching the folders from CK in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(nil, .forwardedError(error))
                return
            }
            guard let records = records else {
                completion(nil, NetworkingError.invalidData("\nInvalid Data"))
                return
            }
            let fetchItems = records.compactMap{ Folder(ckRecord: $0) }
            self.folders = fetchItems
            
            //Test Print
            print("\n📍Number of folders fetched: \(self.folders.count)")
            completion(fetchItems, nil)
        }
    }
    
    // MARK: - Save
    func saveToCloudKit(folder: Folder, completion: @escaping boolVoidCompletion) {
        
        let folderRecord = CKRecord(folder: folder)
        
        privateDB.save(folderRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the folder to cloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newFolderRecord = Folder(ckRecord: record)
                
                else {
                    
                    //Test Print
                    print("\n🤫 No Folder Record was saved to  Cloud😩\n")
                    completion(false)
                    return
            }
            
            self.folders.append(newFolderRecord)
            completion(true)
        }
    }
    
    func createNewFolder(folderTitle: String, completion: @escaping boolVoidCompletion) {
        
        let newFolder = Folder(folderTitle: folderTitle)
        
        saveToCloudKit(folder: newFolder) { (success) in
            if success {
                //Test Print
                print("\n🙏🏽 Succesfully created folder record\n")
                completion(true)
            } else {
                //Test Print
                print("\n💀 Error Creating Folder Record\n")
                completion(false)
                
                //For Test Purposes Only Fatal Error
//                fatalError("\n💀💀Fatal Error, Error creating folder record💀💀\n")
            }
        }
    }
    
    // Creat Entry and Folder
    
    func updateFolder(folder: Folder, folderTitle: String, completion: @escaping boolVoidCompletion) {
        
        folder.folderTitle = folderTitle
        
        let record = CKRecord(folder: folder)
        
        let operration = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operration.savePolicy = .changedKeys
        operration.queuePriority = .high
        operration.qualityOfService = .userInteractive
        operration.completionBlock = {
            
            
            completion(true)
        }
        privateDB.add(operration)
    }
    
    // MARK: - Add Note to the specific Folder 
    func add(note: Note, to folder: Folder) {
        folder.notes.append(note)
    }
}
