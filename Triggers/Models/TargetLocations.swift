//
//  TargetLocation.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class TargetLocation {
    
    var geoCodeAddressString: String
    var addressTitle: String
    //Use the time stamp in order to order
    // USe NSPRedicat  on CloudKit QUerires 
    var timeStamp: Date
    var ckRecordID: CKRecord.ID
    var userReference: CKRecord.Reference
    // double Long and Lat
    var longitude: Double
    var latitude: Double
    
    init(geoCodeAddressString: String, addressTitle: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference, longitude: Double, latitude: Double) {
        self.geoCodeAddressString = geoCodeAddressString
        self.addressTitle = addressTitle
        self.timeStamp = Date()
        self.ckRecordID = ckRecordID
        
        //ASK: DO i need to create a log in?
        self.userReference = userReference
        
        self.longitude = longitude
        self.latitude = latitude
    }
    
    var timeStampAsString: String {
        return DateFormatter.localizedString(from: timeStamp, dateStyle: .short, timeStyle: .short)
    }
    
    // NOTE: - 🔥Fetch Create a model object fromR a CKRecord
    convenience init?(ckRecord: CKRecord) {
        //Step 1. Unpack the values that i want from the CKREcord
        guard let geoCodeAddressString = ckRecord[LocationConstants.geoCodeAddressStringKey] as? String,
            let addressTitle = ckRecord[LocationConstants.addressTitleKey] as? String,
        let userReference = ckRecord[LocationConstants.usersLocationRefKey] as? CKRecord.Reference,
            let longitude = ckRecord[LocationConstants.longitudeKey] as? Double,
        let latitude = ckRecord[LocationConstants.latitudeKey] as? Double
        else {return nil}

        // Step 2. Set tthose values as my initial values for my new instance
        self.init(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, ckRecordID: ckRecord.recordID, userReference: userReference, longitude: longitude, latitude: latitude)
//        self.usersLocationRefrence = usersLocationRefrence

    }
}

// NOTE: - 🔥Push -- Create a CKRecord using our model object
extension CKRecord {
    convenience init(targetLocation: TargetLocation) {
    
        self.init(recordType: LocationConstants.TargetLocationKey, recordID: targetLocation.ckRecordID)
        self.setValue(targetLocation.geoCodeAddressString, forKey: LocationConstants.geoCodeAddressStringKey)
        self.setValue(targetLocation.addressTitle, forKey: LocationConstants.addressTitleKey)
        self.setValue(targetLocation.timeStamp, forKey: LocationConstants.timeStampKey)
        self.setValue(targetLocation.userReference, forKey: LocationConstants.usersLocationRefKey)
        self.setValue(targetLocation.longitude, forKey: LocationConstants.longitudeKey)
        self.setValue(targetLocation.latitude, forKey: LocationConstants.latitudeKey)
        
    }
}

extension TargetLocation: Equatable {
    static func == (lhs: TargetLocation, rhs: TargetLocation) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID {return false}
        
        return true
    }
}
