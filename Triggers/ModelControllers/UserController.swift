//
//  UserDetailsController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    //      static let usersLocationRefKey = "usersLocationRefKey"
    
    static let shared = UserController()
    
    private init() {}
    
    var loggedInUser: User?
    
    var appleUserRecordID: CKRecord.ID?
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = (Bool, NetworkingError?) -> Void
    
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    func fetchCurrentUser(completion: @escaping fetchCompletion) {
        
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("\n\n🚀 There was an error with fetching users ID in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false , .forwardedError(error))
                return
            }
            
            guard let recordID = recordID else { completion(false, .invalidData("Record ID is invalid"))
                return
            }
            
            self.appleUserRecordID = recordID
            
            
            let predicate = NSPredicate(format: "\(UserConstants.appleUserRefKey) == %@", recordID)
            /*
             add this to the location controller
             let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userDetailsReference)
             */
            
            // Create the query object, and set the sort order.
            let query = CKQuery(recordType: UserConstants.userTypeKey, predicate: predicate)
            
            self.privateDB.perform(query, inZoneWith: nil) { (records, error) in
                
                if let error = error {
                    print("\n\n🚀 There was an error with fetching the records in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                    completion(false, .forwardedError(error))
                    return
                }
                // Make sure we have records
                guard let records = records, let userRecord = records.first else {
                    completion(false, .invalidData("\nINvalid Data\n"))
                    return
                }
                self.loggedInUser = User(ckRecord: userRecord)
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Save
    func saveToCloudKit(user: User, completion: @escaping boolVoidCompletion) {
        
        let userRecord = CKRecord(user: user)
        
        privateDB.save(userRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            
            self.loggedInUser = user
            
            completion(true)
        }
    }
    
    // MARK: - Create
    func createNewUserDetailsWith(userName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        
        //new
        guard let appleUserRecordID = appleUserRecordID else { completion(false) ; return }
        
        let appleUserRef = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
        
        let user = User(userName: userName, sponsorName: sponsorName, sponsorTelephoneNumber: sponserTelephoneNumber, sponsorEmail: sponsorEmail, aaStep: aaStep, appleUserRef: appleUserRef)
        
        saveToCloudKit(user: user) { (success) in
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
    func updateUserDetails(user: User, userName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        user.userName = userName
        user.sponsorName = sponsorName
        user.sponsorTelephoneNumber = sponserTelephoneNumber
        user.sponsorEmail = sponsorEmail
        user.aaStep = aaStep
        let record = CKRecord(user: user )
        
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
