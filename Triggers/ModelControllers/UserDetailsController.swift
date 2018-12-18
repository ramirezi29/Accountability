//
//  UserDetailsController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class UserDetailsController {
    
    //      static let usersLocationRefKey = "usersLocationRefKey"
    
    static let shared = UserDetailsController()
    
    private init() {}
    
    var userDetails =  [UserDetails]()
    
    var usersLocationRefrence: CKRecord.ID?
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = ([UserDetails]?, NetworkingError?) -> Void
    
    // MARK: - Fetch
    func fetchItems(userDetails: UserDetails, completion: @escaping fetchCompletion) {
        
        // Match item records whose owningList(newsletter) field points to the specified list record (instance of Newsletter)
        guard let userDetailsParentID = userDetails.ckRecordID else {return}
        let userDetailsReference = CKRecord.Reference(recordID: userDetailsParentID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userDetailsReference)
        
        // Create the query object, and set the sort order.
        let query = CKQuery(recordType: UserDetailConstants.UserDetailsKey, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: LocationConstants.timeStampKey, ascending: true)]
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
            let fetchedItems = records.compactMap{ UserDetails(ckRecord: $0) }
            self.userDetails = fetchedItems
            completion(fetchedItems, nil)
        }
    }
    
    // MARK: - Save
    func saveToCloudKit(userDetails: UserDetails, completion: @escaping (Bool) -> Void) {
        let userDetailRecord = CKRecord(userDetails: userDetails)
        
        privateDB.save(userDetailRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newUseretail = UserDetails(ckRecord: record) else {
                print("\n💀 No Record came back from CloudKit\n")
                completion(false)
                return
            }
            self.userDetails.append(newUseretail)
            completion(true)
        }
    }
    
    func createNewUserDetailsWith(sponseeName: String, sponsorName: String, sponserTelephoneNumber: String, aaStep: Int, completion: @escaping (Bool) -> Void) {
        
        
    }
}


/*  typealias fetchCharacterCompletion =  ([CharacterResult]?, NetworkingError?) -> Void
 
 typealias FetchImageCompletion = ((UIImage?), NetworkingError?) -> Void*/
