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
    func fetchItemsFor(user: User? = UserController.shared.loggedInUser, completion: @escaping fetchCompletion) {
        
        print("☃️When this page was loaded and the fetch func was first called there were \(locations.count) found")
        
        guard let user = user else {
            completion(nil, .invalidData("Invalid User"))
            return
        }
        print("\n🐇Location Controller has user's print out as: \(user)\n \(String(describing: user.sponsorName))\n userRef: \(user.appleUserRef)\n ckRed: \(String(describing: user.ckRecordID))")
        
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
            print("🎸 The fetch func finished fetching and there are: \(self.locations.count) locations")
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
                print("\n💀 No Record was saved to CloudKit\n")
                completion(false)
                return
            }
            self.locations.append(newlocationRecord)
            completion(true)
        }
    }
    
    // MARK: - Create
    func createNewLocation(geoCodeAddressString: String, addressTitle: String, longitude: Double, latitude: Double, completion: @escaping boolVoidCompletion) {
        
        let newLocation = Location(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, longitude: longitude, latitude: latitude)
        
        saveToCloudKit(locations: newLocation) { (success) in
            if success {
                print("\n🙏🏽Successfully created record\n")
                completion(true)
            } else {
                //Test Print
                print("\n💀Error Creating LocationRecord\n")
                
                completion(false)
                //for test purposes fatal error
//                fatalError("\n💀💀Fatal Error , error creating location record💀💀\n")
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
            
            NotificationController.cancelLocalNotificationWith(identifier: location.locationTitle)
            
            completion(true)
        }
        privateDB.add(operration)
    }
}
