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

class User {
    var userName: String
    var sponsorName: String?
    var sponsorTelephoneNumber: String?
    var sponsorEmail: String?
    var aaStep: Int
    var ckRecordID: CKRecord.ID?
    // Create a User Ref
    
    var targetLocations: [Location] = []
    
    var notes: [Note] = []
    
    init(userName: String, sponsorName: String, sponsorTelephoneNumber: String, sponsorEmail: String, aaStep: Int, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.userName = userName
        self.sponsorName = sponsorName
        self.sponsorTelephoneNumber = sponsorTelephoneNumber
        self.aaStep = aaStep
        self.ckRecordID = ckRecordID
        self.sponsorEmail = sponsorEmail
        
    }
    
    // NOTE: - Create a model object fromR a CKRecord -- 🔥Fetch
    convenience init?(ckRecord: CKRecord) {
        
        guard let userName = ckRecord[UserConstants.sponseeNameKey] as? String,
            
            let sponsorName = ckRecord[UserConstants.sponsorNameKey] as? String,
            
            let sponsorTelephoneNumber = ckRecord[UserConstants.sponsorTelephoneNumberKey] as? String,
            
            let sponsorEmail = ckRecord[UserConstants.sponsorEmailKey] as? String,
            
            let aaStep = ckRecord[UserConstants.aaStepKey] as? Int
            
            else {return nil}
        
        
        self.init(userName: userName, sponsorName: sponsorName, sponsorTelephoneNumber: sponsorTelephoneNumber, sponsorEmail: sponsorEmail, aaStep: aaStep, ckRecordID: ckRecord.recordID)
    }
}

// NOTE: - Create a CKRecord using our model object -- 🔥Pushextension user {
extension CKRecord {
    convenience init(user: User) {
        
        let recordID = user.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        
        self.init(recordType: UserConstants.userTypeKey, recordID: recordID)
        
        self.setValue(user.userName, forKey: UserConstants.sponseeNameKey)
        
        self.setValue(user.sponsorName, forKey: UserConstants.sponsorNameKey)
        
        self.setValue(user.sponsorTelephoneNumber, forKey: UserConstants.sponsorTelephoneNumberKey)
        
        self.setValue(user.sponsorEmail, forKey: UserConstants.sponsorEmailKey)
        
        self.setValue(user.aaStep, forKey: UserConstants.aaStepKey)
            
       // NOTE: - In order to not save a brand new record
        user.ckRecordID = recordID
    }
}


extension User: Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID {return false}
        
        return true
    }
}
