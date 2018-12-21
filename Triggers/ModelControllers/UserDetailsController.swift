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
    
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    func fetchItems(userDetails: UserDetails, completion: @escaping fetchCompletion) {
        
        // Match item records whose owningList(newsletter) field points to the specified list record (instance of Newsletter)
        guard let userDetailsParentID = userDetails.ckRecordID else {return}
        let userDetailsReference = CKRecord.Reference(recordID: userDetailsParentID, action: .deleteSelf)
        
        // MARK: - Test this to see if the predicate should be Value(true)
        let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userDetailsReference)
        
        /*
         add this to the location controller
          let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userDetailsReference)
         */
        
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
    func saveToCloudKit(userDetails: UserDetails, completion: @escaping boolVoidCompletion) {
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
    
    // MARK: - Create
    func createNewUserDetailsWith(sponseeName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        
        let userDetails = UserDetails(sponseeName: sponseeName, sponsorName: sponsorName, sponsorTelephoneNumber: sponserTelephoneNumber, sponsorEmail: sponsorEmail, aaStep: aaStep)

        saveToCloudKit(userDetails: userDetails) { (success) in
            if success {
                print("\n🙏🏽Successfully created record\n")
                completion(true)
            } else {
                completion(false)
                print("\n💀Error Creating Record💀\n")
                //for test purposes fatal error
//                fatalError("\nFatal Error , error creating record\n")
            }
        }
        
    }
    
    // MARK: - Update
    func updateUserDetails(userDetails: UserDetails, sponseeName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        userDetails.sponseeName = sponseeName
        userDetails.sponsorName = sponsorName
        userDetails.sponsorTelephoneNumber = sponsorName
        userDetails.sponsorEmail = sponsorEmail
        
        let record = CKRecord(userDetails: userDetails)
        
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


/*  typealias fetchCharacterCompletion =  ([CharacterResult]?, NetworkingError?) -> Void
 
 typealias FetchImageCompletion = ((UIImage?), NetworkingError?) -> Void*/
