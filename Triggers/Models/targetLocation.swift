//
//  TargetLocation.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class TargetLocations {
    
    var geoCodeAddressString: String
    var addressTitle: String
    //Use the time stamp in order to order
    // USe NSPRedicat  on CloudKit QUerires 
    var timeStamp: Date
    let ckRecord: CKRecord.ID
    // double Long and Lat
    
    init(geoCodeAddressString: String, addressTitle: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.geoCodeAddressString = geoCodeAddressString
        self.addressTitle = addressTitle
        self.timeStamp = Date()
        self.ckRecord = ckRecordID
    }
    
    var timeStampAsString: String {
        return DateFormatter.localizedString(from: timeStamp, dateStyle: .short, timeStyle: .short)
    }
    
    // NOTE: - 🔥Fetch Create a model object fromR a CKRecord
    convenience init?(ckRecord: CKRecord) {
        //Step 1. Unpack the values that i want from the CKREcord
        guard let geoCodeAddressString = ckRecord[LocationConstants.geoCodeAddressStringKey] as? String,
            let addressTitle = ckRecord[LocationConstants.addressTitleKey] as? String else {return nil}
        // Step 2. Set tthose values as my initial values for my new instance
        self.init(geoCodeAddressString: geoCodeAddressString, addressTitle: addressTitle, ckRecordID: ckRecord.recordID)
    }
}

// NOTE: - 🔥Push -- Create a CKRecord using our model object
extension CKRecord {
    convenience init(targetLocation: TargetLocations) {
        self.init(recordType: LocationConstants.TargetLocationKey, recordID: targetLocation.ckRecord)
        self.setValue(targetLocation.geoCodeAddressString, forKey: LocationConstants.geoCodeAddressStringKey)
        self.setValue(targetLocation.addressTitle, forKey: LocationConstants.addressTitleKey)
        self.setValue(targetLocation.timeStamp, forKey: LocationConstants.timeStampKey)
    }
}

extension TargetLocations: Equatable {
    static func == (lhs: TargetLocations, rhs: TargetLocations) -> Bool {
        if lhs.ckRecord != rhs.ckRecord {return false}
        
        return true
    }
}
