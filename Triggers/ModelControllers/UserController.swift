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
    
    static let shared = UserController()
    private init() {}
    var loggedInUser: User?
    var appleUserRecordID: CKRecord.ID?
    let privateDB = CKContainer.default().privateCloudDatabase
    typealias fetchCompletion = (Bool, NetworkingError?) -> Void
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    
    /**
     Fetch the user's details.
     
     ## Important Note ##
     - The device must be signed into an iCloud account and be connected to the internet
     */
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
    
    /**
     Save the user's details to  iCloud
     
     - Parameter user: User Object
     
     ## Important Note ##
     - The device must be signed into an iCloud account and be connected to the internet
     */
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
    
    /**
     Create CloudKit User object
     
     - Parameter userName: String description of the user's name
     - Parameter sponsorName: String description of the sponsor's name
     - Parameter sponserTelephoneNumber: String description ofthe sponsor's telephone number
     - Parameter sponsorEmail: String description of the sponsor's e-mail
     - Parameter aaStep: String description of the user's current AA step
     
     ## Important Note ##
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func createNewUserDetailsWith(userName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        
        guard let appleUserRecordID = appleUserRecordID else { completion(false)
            return
        }
        
        let appleUserRef = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
        
        let user = User(userName: userName, sponsorName: sponsorName, sponsorTelephoneNumber: sponserTelephoneNumber, sponsorEmail: sponsorEmail, aaStep: aaStep, appleUserRef: appleUserRef)
        
        saveToCloudKit(user: user) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
                //for test purposes fatal error
                //fatalError("\nFatal Error , error creating record\n")
            }
        }
        
    }
    
    // MARK: - Update
    
    /**
     Update CloudKit User object with high que priority
     
     - Parameter user: The User object that is to be updated
     - Parameter userName: String description of the user's name
     - Parameter sponsorName: String description of the sponsor's name
     - Parameter sponserTelephoneNumber: String description ofthe sponsor's telephone number
     - Parameter sponsorEmail: String description of the sponsor's e-mail
     - Parameter aaStep: String description of the user's current AA step
     
     ## Important Note ##
     - A valid User object must already exist
     -The device must be signed into an iCloud account and be connected to the internet
     */
    func updateUserDetails(user: User, userName: String, sponsorName: String, sponserTelephoneNumber: String, sponsorEmail: String, aaStep: Int, completion: @escaping boolVoidCompletion) {
        user.userName = userName
        user.sponsorName = sponsorName
        user.sponsorTelephoneNumber = sponserTelephoneNumber
        user.sponsorEmail = sponsorEmail
        user.aaStep = aaStep
        
        let record = CKRecord(user: user )
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
