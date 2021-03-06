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
    var locationUserRecordID: CKRecord.ID?
    typealias fetchCompletion = ([Location]?, NetworkingError?) -> Void
    typealias boolVoidCompletion = (Bool) -> Void
    
    // MARK: - Fetch
    /**
     Fetch CloudKit location object. This is done by querying the User object's CKRecordID with the LocationConstants' usersLocationRefKey and LocationTypeKey.
     
     - Parameter user: The User object which the location records will be fetched from.
     
     ## Important Note ##
     - A valid User object must already exist
     - The device must be signed into an iCloud account and be connected to the internet
     */
    func fetchItemsFor(user: User? = UserController.shared.loggedInUser, completion: @escaping fetchCompletion) {
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
            // NOTE: - Make sure there are records
            guard let records = records else {
                completion(nil, .invalidData("\nINvalid Data\n"))
                return
            }
            let fetchItems = records.compactMap { Location(ckRecord: $0) }
            self.locations = fetchItems
            
            completion(fetchItems, nil)
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
    func saveToCloudKit(locations: Location, completion: @escaping boolVoidCompletion) {
        let locationRecord = CKRecord(location: locations)
        privateDB.save(locationRecord) { (record, error) in
            if let error = error {
                print("\n\n🚀 There was an error with saving the record to CloudKit in: \(#file) \n\n \(#function); \n\n\(error); \n\n\(error.localizedDescription) 🚀\n\n")
                completion(false)
                return
            }
            guard let record = record, let newlocationRecord = Location(ckRecord: record) else {
                completion(false)
                return
            }
            self.locations.append(newlocationRecord)
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
    func createNewLocation(geoCodeAddressString: String, addressTitle: String, longitude: Double, latitude: Double, completion: @escaping boolVoidCompletion) {
        
        let newLocation = Location(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, longitude: longitude, latitude: latitude)
        
        saveToCloudKit(locations: newLocation) { (success) in
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
            
            NotificationController.cancelLocalNotificationWith(identifier: location.locationTitle)
            
            completion(true)
        }
        privateDB.add(operration)
    }
}
