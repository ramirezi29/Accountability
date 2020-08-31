//
//  SobrietyController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 8/30/20.
//  Copyright © 2020 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class SobrietyController {
    
    static let shared = SobrietyController()
    private init() {}
    var sobriety = [Sobriety]()
    let privateDB = CKContainer.default().privateCloudDatabase
    var sobrietyRecordID: CKRecord.ID?
    
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    /**
     Fetch CloudKit sobriety object. This is done by querying the User object's CKRecordID with the SobrietyConstants' ref key and Sobriety typ ekey.
     
     - Parameter user: The User object which the location records will be fetched from.
     
     ## Important Note ##
     - A valid User object must already exist
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func fetchItemsFor(user: User? = UserController.shared.loggedInUser, completion: @escaping (Result<Sobriety, Error>) -> Void) {
        guard let user = user else {
            completion(.failure(NetworkingError.invalidData("User is nil")))
            return
        }
        
        guard let userParentID = user.ckRecordID else {
            completion(.failure(NetworkingError.invalidData("user parent id nil")))
            return
        }
        
        let predicate = NSPredicate(format: "\(SobrietyConstants.sobreityRefKey) == %@", userParentID)
        let query = CKQuery(recordType: SobrietyConstants.sobrietyTypeKey, predicate: predicate)
        
        //🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDatey", ascending: true)]
        
        privateDB.perform(query, inZoneWith: nil) { (record, error) in
            
            if let error = error {
                print("\n\n🚀 There was an error with fetching the records in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(.failure(NetworkingError.forwardedError(error)))
                return
            }
            // NOTE: - Make sure there are records
            guard let record = record else {
                completion(.failure(NetworkingError.invalidData("invalid record")))
                return
            }
            let fetchSobrietyDate = record.compactMap {Sobriety(ckRecord: $0)}
            self.sobriety = fetchSobrietyDate
            
            completion(.success(fetchSobrietyDate[0]))
        }
    }
    
    // MARK: - Save
    /**
     Save a Location object to CloudKit
     
     - Parameter locations: A Location object.
     
     ## Important Note ##
     - A valid User object must already exist
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func saveToCloudKit(sobriety: Sobriety, completion: @escaping (Bool) -> Void) {
        let sobrietyRecord = CKRecord(sobriety: sobriety)
        privateDB.save(sobrietyRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newSobrietyDate = Sobriety(ckRecord: record) else {
                completion(false)
                return
            }
            self.sobriety.append(newSobrietyDate)
            completion(true)
        }
    }
    
    // MARK: - Create
    /**
     Create a new Location object to CloudKit
     
     - Parameter geoCodeAddressString: The String address of the loction.
     - Parameter addressTitle: The String address title
     - Parameter longitude: The longitude Double of the address.
     - Parameter latitude: The latitude Double of the address.
     
     
     ## Important Note ##
     - A valid User object must already exist
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func createSobrietyDate(sobrietyDate: Date, completion: @escaping boolVoidCompletion) {
        
        let newSobrietyDate = Sobriety(sobrietyDate: sobrietyDate)
        
        saveToCloudKit(sobriety: newSobrietyDate) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /**
     Create a new Location object to CloudKit with que priority set to high
     
     - Parameter location: The Location object.
     - Parameter geoCodeAddressString: The String address of the loction.
     - Parameter addressTitle: The String address title
     - Parameter longitude: The longitude Double of the address.
     - Parameter latitude: The latitude Double of the address.
     
     
     ## Important Note ##
     - A valid User object must already exist
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func updatedSobreityDate(sobriety: Sobriety, sobrietyDate: Date) {
        
        sobriety.sobrietyDate = sobrietyDate
        
        let record = CKRecord(sobriety: sobriety)
        
        let operration = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operration.savePolicy = .changedKeys
        operration.queuePriority = .high
        operration.qualityOfService = .userInteractive
        operration.completionBlock = {
        }
        privateDB.add(operration)
    }
}
