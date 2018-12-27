//
//  TargetLocationController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/20/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class LocationController {
    
    static let shared = LocationController()
    
    private init() {}
    
    var locations = [Location]()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    typealias fetchCompletion = ([Location]?, NetworkingError?) -> Void
    typealias boolVoidCompletion = (Bool) -> Void
    
    //    func fetchItems(locations: Location, completion: @escaping fetchCompletion) {
    //    func fetchItemsFor(user: User, completion: @escaping fetchCompletion) {
    
    // MARK: - Fetch
    func fetchItemsFor(user: User? = UserController.shared.loggedInUser, completion: @escaping fetchCompletion) {
        // MARK: - This might need to be the ckRecordID for the parent not location
        guard let user = user else {
            completion(nil, .invalidData("Invalid User"))
            return
        }
        
       guard let userParentID = user.ckRecordID else {
            completion(nil, .invalidData("Invalid User Parent ID"))
            return
        }
 
        let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userParentID)
        
        let query = CKQuery(recordType: LocationConstants.LocationTypeKey, predicate: predicate)
        
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
            let fetchItems = records.compactMap{ Location(ckRecord: $0) }
            self.locations = fetchItems
            completion(fetchItems, nil)
        }
    }
    
    // MARK: - Save
    func saveToCloudKit(locations: Location, completion: @escaping boolVoidCompletion) {
        
        let locationRecord = CKRecord(location: locations)
        privateDB.save(locationRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newlocationRecord = Location(ckRecord: record) else {
                print("\n💀 No Record came back from CloudKit\n")
                completion(false)
                return
            }
            self.locations.append(newlocationRecord)
            completion(true)
        }
    }
    
    // MARK: - Create
    func createNewLocation(location: Location, geoCodeAddressString: String, addressTitle: String, userTargetLocationReference: CKRecord.Reference, longitude: Double, latitude: Double, completion: @escaping boolVoidCompletion) {
        
        let locationRecordID = location.ckRecordID
        let userLocationReference = CKRecord.Reference(recordID: locationRecordID , action: .deleteSelf)
        //ASK: Why did are thsee dot syntax
        let latitude = location.latitude
        let longitude = location.longitude
        
        let newLocation = Location(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, userLocationReference: userLocationReference, longitude: longitude, latitude: latitude)
        
        saveToCloudKit(locations: newLocation) { (success) in
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
    
    func updateTargetLocation(location: Location, geoCodeAddressString: String, addressTitle: String, latitude: Double, longitude: Double, completion: @escaping boolVoidCompletion) {
        
        location.geoCodeAddressString = geoCodeAddressString
        location.locationTitle = addressTitle
        location.latitude = latitude
        location.longitude = longitude
        
        let record = CKRecord(location: location)
        
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


/*
 
 import Foundation
 import CloudKit
 
 class LocationController {
 
 static let shared = LocationController()
 
 private init() {}
 
 var locations = [Location]()
 
 let privateDB = CKContainer.default().privateCloudDatabase
 
 typealias fetchCompletion = ([Location]?, NetworkingError?) -> Void
 typealias boolVoidCompletion = (Bool) -> Void
 
 //    func fetchItems(locations: Location, completion: @escaping fetchCompletion) {
 func fetchItemsFor(user: User, completion: @escaping fetchCompletion) {
 // MARK: - This might need to be the ckRecordID for the parent not location
 guard let userParentID = user.ckRecordID else {
 completion(nil, .invalidData("Invalid User Parent ID"))
 return
 }
 
 //        let userLocationReference = CKRecord.Reference(recordID: userParentID, action: .deleteSelf)
 
 
 let predicate = NSPredicate(format: "\(LocationConstants.usersLocationRefKey) == %@", userParentID)
 
 let query = CKQuery(recordType: LocationConstants.LocationTypeKey, predicate: predicate)
 
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
 let fetchItems = records.compactMap{ Location(ckRecord: $0) }
 self.locations = fetchItems
 completion(fetchItems, nil)
 }
 }
 
 func saveToCloudKit(locations: Location, completion: @escaping boolVoidCompletion) {
 let locationRecord = CKRecord(location: locations)
 privateDB.save(locationRecord) { (record, error) in
 if let error = error {
 print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
 completion(false)
 return
 }
 guard let record = record, let newlocationRecord = Location(ckRecord: record) else {
 print("\n💀 No Record came back from CloudKit\n")
 completion(false)
 return
 }
 self.locations.append(newlocationRecord)
 completion(true)
 }
 }
 
 func createNewLocation(location: Location, geoCodeAddressString: String, addressTitle: String, userTargetLocationReference: CKRecord.Reference, longitude: Double, latitude: Double, completion: @escaping boolVoidCompletion) {
 
 let locationRecordID = location.ckRecordID
 let userLocationReference = CKRecord.Reference(recordID: locationRecordID , action: .deleteSelf)
 let latitude = location.latitude
 let longitude = location.longitude
 
 let newLocation = Location(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, userLocationReference: userLocationReference, longitude: longitude, latitude: latitude)
 
 saveToCloudKit(locations: newLocation) { (success) in
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
 
 func updateTargetLocation(location: Location, geoCodeAddressString: String, addressTitle: String, latitude: Double, longitude: Double, completion: @escaping boolVoidCompletion) {
 
 location.geoCodeAddressString = geoCodeAddressString
 location.locationTitle = addressTitle
 location.latitude = latitude
 location.longitude = longitude
 
 let record = CKRecord(location: location)
 
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
 */
