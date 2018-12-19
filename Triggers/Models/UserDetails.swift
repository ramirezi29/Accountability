//
//  Dashboard.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

// Create a log in process where they enter in the stuff to present in the dash board screen

class UserDetails {
    var sponseeName: String
    var sponsorName: String?
    var sponsorTelephoneNumber: String
    
    var aaStep: Int?
    var ckRecordID: CKRecord.ID?
    //Dont need a refence 
    
    var targetLocations: [TargetLocations] = []
    
    init(sponseeName: String, sponsorName: String, sponsorTelephoneNumber: String, aaStep: Int, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.sponseeName = sponseeName
        self.sponsorName = sponsorName
        self.sponsorTelephoneNumber = sponsorTelephoneNumber
        self.aaStep = aaStep
        self.ckRecordID = ckRecordID
        
    }
    
    // NOTE: - Create a model object fromR a CKRecord -- 🔥Fetch
    convenience init?(ckRecord: CKRecord) {
        guard let sponseeName = ckRecord[UserDetailConstants.sponseeNameKey] as? String,
            let sponsorName = ckRecord[UserDetailConstants.sponsorNameKey] as? String,
            let sponsorTelephoneNumber = ckRecord[UserDetailConstants.sponsorTelephoneNumberKey] as? String,
            let aaStep = ckRecord[UserDetailConstants.aaStepKey] as? Int
        
            else {return nil}
        
        self.init(sponseeName: sponseeName, sponsorName: sponsorName, sponsorTelephoneNumber: sponsorTelephoneNumber, aaStep: aaStep, ckRecordID: ckRecord.recordID)
    }
}

// NOTE: - Create a CKRecord using our model object -- 🔥Pushextension UserDetails {
extension CKRecord {
    convenience init(userDetails: UserDetails) {
        let recordID = userDetails.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        self.init(recordType: UserDetailConstants.UserDetailsKey, recordID: recordID)
        self.setValue(userDetails.sponseeName, forKey: UserDetailConstants.sponseeNameKey)
        self.setValue(userDetails.sponsorTelephoneNumber, forKey: UserDetailConstants.sponsorTelephoneNumberKey)
        self.setValue(userDetails.aaStep, forKey: UserDetailConstants.aaStepKey)
        
        
       // NOTE: - In order to not save a branch new record
        userDetails.ckRecordID = recordID
    }
}


extension UserDetails: Equatable {
    
    static func == (lhs: UserDetails, rhs: UserDetails) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID {return false}
        
        return true
    }
}
