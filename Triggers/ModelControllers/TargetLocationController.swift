//
//  TargetLocationController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/20/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit


class TargetLocationController {
    
    static let shared = TargetLocationController()
    
    private init() {}
    
    var targetLocations = [TargetLocation]()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = ([TargetLocation]?, NetworkingError?) -> Void
    typealias boolVoidCompletion = (Bool) -> Void
    
    func fetchItems(targetLocations: TargetLocation, completion: @escaping fetchCompletion) {
        
        // MARK: - This might need to be the ckRecordID for the parent not location
        let locationParentID = targetLocations.ckRecordID
        let userLocationReference = CKRecord.Reference(recordID: locationParentID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userLocationReference)
        
        let query = CKQuery(recordType: LocationConstants.TargetLocationKey, predicate: predicate)
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
            let fetchItems = records.compactMap{ TargetLocation(ckRecord: $0) }
            self.targetLocations = fetchItems
            completion(fetchItems, nil)
        }
    }
    
    func saveToCloudKit(targetLocations: TargetLocation, completion: @escaping boolVoidCompletion) {
        let targetLocationRecord = CKRecord(targetLocation: targetLocations)
        privateDB.save(targetLocationRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newTargetLocation = TargetLocation(ckRecord: record) else {
                print("\n💀 No Record came back from CloudKit\n")
                completion(false)
                return
            }
            self.targetLocations.append(newTargetLocation)
            completion(true)
        }
    }
    
    func createNewTargetLocation(targetLocation: TargetLocation, geoCodeAddressString: String, addressTitle: String, userTargetLocationReference: CKRecord.Reference, longitude: Double, latitude: Double, completion: @escaping boolVoidCompletion) {
        
        let targetLocationecordID = targetLocation.ckRecordID
        let userTargetLocationReference = CKRecord.Reference(recordID: targetLocationecordID , action: .deleteSelf)
        let latitude = targetLocation.latitude
        let longitude = targetLocation.longitude
        
        let newTargetLocation = TargetLocation(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, userReference: userTargetLocationReference, longitude: longitude, latitude: latitude)
        
        saveToCloudKit(targetLocations: newTargetLocation) { (success) in
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
    
    func updateTargetLocation(targetLocation: TargetLocation, geoCodeAddressString: String, addressTitle: String, latitude: Double, longitude: Double, completion: @escaping boolVoidCompletion) {
        
        targetLocation.geoCodeAddressString = geoCodeAddressString
        targetLocation.addressTitle = addressTitle
        targetLocation.latitude = latitude
        targetLocation.longitude = longitude
        
        let record = CKRecord(targetLocation: targetLocation)
        
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
