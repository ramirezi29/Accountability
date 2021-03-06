//
//  TargetLocation.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class Location {
    
    var geoCodeAddressString: String
    var locationTitle: String
    var longitude: Double
    var latitude: Double
    var timeStamp: Date
    var ckRecordID: CKRecord.ID
    var userLocationReference: CKRecord.Reference?
    
    init(geoCodeAddressString: String, addressTitle: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), longitude: Double, latitude: Double) {
        
        self.geoCodeAddressString = geoCodeAddressString
        self.locationTitle = addressTitle
        self.timeStamp = Date()
        self.longitude = longitude
        self.latitude = latitude
        self.ckRecordID = ckRecordID
        
        if let currentUserID = UserController.shared.loggedInUser?.ckRecordID {
            self.userLocationReference = CKRecord.Reference(recordID: currentUserID, action: .deleteSelf)
        }
    }
    
    var timeStampAsString: String {
        return DateFormatter.localizedString(from: timeStamp, dateStyle: .short, timeStyle: .short)
    }
    
    // NOTE: - Fetch Create a model object fromR a CKRecord
    convenience init?(ckRecord: CKRecord) {
        //Step 1. Unpack the values that are linked to the CKRecord
        guard let geoCodeAddressString = ckRecord[LocationConstants.geoCodeAddressStringKey] as? String,
            
            let addressTitle = ckRecord[LocationConstants.locationTitleKey] as? String,
            
            let longitude = ckRecord[LocationConstants.longitudeKey] as? Double,
            
            let latitude = ckRecord[LocationConstants.latitudeKey] as? Double
            
            else { return nil }
        
        let userLocationReference = ckRecord[LocationConstants.usersLocationRefKey] as? CKRecord.Reference
        // Step 2. Set those values as initial values for a new instance
        self.init(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, ckRecordID: ckRecord.recordID, longitude: longitude, latitude: latitude)
        
        self.userLocationReference = userLocationReference
        
    }
}

// NOTE: Push - Create a CKRecord using our model object
extension CKRecord {
    convenience init(location: Location) {
        
        self.init(recordType: LocationConstants.LocationTypeKey, recordID: location.ckRecordID)
        
        self.setValue(location.geoCodeAddressString, forKey: LocationConstants.geoCodeAddressStringKey)
        self.setValue(location.locationTitle, forKey: LocationConstants.locationTitleKey)
        self.setValue(location.timeStamp, forKey: LocationConstants.timeStampKey)
        self.setValue(location.userLocationReference, forKey: LocationConstants.usersLocationRefKey)
        self.setValue(location.longitude, forKey: LocationConstants.longitudeKey)
        self.setValue(location.latitude, forKey: LocationConstants.latitudeKey)
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        
        return true
    }
}
