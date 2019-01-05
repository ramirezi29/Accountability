//
//  Dashboard.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class User {
    var userName: String
    var sponsorName: String?
    var sponsorTelephoneNumber: String?
    var sponsorEmail: String?
    var aaStep: Int
    var ckRecordID: CKRecord.ID?
//    let userRecord: CKRecord
    var appleUserRef: CKRecord.Reference
    
    var targetLocations: [Location] = []
    
    var folders: [Folder] = []
    
    var notes: [Note] = []
    
//    let customZoneID = CKRecordZone.ID(zoneName: UserConstants.zoneName, ownerName: CKCurrentUserDefaultName)
    
    
//    let share = CKShare(rootRecord: <#T##CKRecord#>)
  
    
    init(userName: String, sponsorName: String, sponsorTelephoneNumber: String, sponsorEmail: String, aaStep: Int, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference) {
        
        
        
        self.userName = userName
        self.sponsorName = sponsorName
        self.sponsorTelephoneNumber = sponsorTelephoneNumber
        self.aaStep = aaStep
        self.ckRecordID = ckRecordID
        self.sponsorEmail = sponsorEmail
        self.appleUserRef = appleUserRef
    }
    
    // NOTE: - Create a model object fromR a CKRecord -- 🔥Fetch
    convenience init?(ckRecord: CKRecord) {
        
        guard let userName = ckRecord[UserConstants.sponseeNameKey] as? String,
            
            let sponsorName = ckRecord[UserConstants.sponsorNameKey] as? String,
            
            let sponsorTelephoneNumber = ckRecord[UserConstants.sponsorTelephoneNumberKey] as? String,
            
            let sponsorEmail = ckRecord[UserConstants.sponsorEmailKey] as? String,
            
            let aaStep = ckRecord[UserConstants.aaStepKey] as? Int,
            
            let appleUserRef = ckRecord[UserConstants.appleUserRefKey] as? CKRecord.Reference
            
            else {return nil}
        
        
        self.init(userName: userName, sponsorName: sponsorName, sponsorTelephoneNumber: sponsorTelephoneNumber, sponsorEmail: sponsorEmail, aaStep: aaStep, ckRecordID: ckRecord.recordID, appleUserRef: appleUserRef)
    }
}

// NOTE: - Create a CKRecord using our model object -- 🔥Push
extension CKRecord {
    convenience init(user: User) {
        
        let recordID = user.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        
        self.init(recordType: UserConstants.userTypeKey, recordID: recordID)
        self.setValue(user.userName, forKey: UserConstants.sponseeNameKey)
        self.setValue(user.sponsorName, forKey: UserConstants.sponsorNameKey)
        self.setValue(user.sponsorTelephoneNumber, forKey: UserConstants.sponsorTelephoneNumberKey)
        self.setValue(user.sponsorEmail, forKey: UserConstants.sponsorEmailKey)
        self.setValue(user.aaStep, forKey: UserConstants.aaStepKey)
        self.setValue(user.appleUserRef, forKey: UserConstants.appleUserRefKey)
        
        
        
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


/*
 // Note: employeeRecord is the CKRecord I need to share
 
 
 let share = CKShare(rootRecord: employeeRecord)
 
 
 share[CKShareTitleKey] = "Some title" as CKRecordValue?share[CKShareTypeKey] = "Some type" as CKRecordValue?
 
 
 let sharingController = UICloudSharingController
 
 (preparationHandler: {(UICloudSharingController, handler:
 @escaping (CKShare?, CKContainer?, Error?) -> Void) in
 
 
 let modifyOp = CKModifyRecordsOperation(recordsToSave:
 [employeeRecord, share], recordIDsToDelete: nil)
 modifyOp.modifyRecordsCompletionBlock = { (record, recordID,
 error) in
 
 handler(share, CKContainer.default(), error)
 }
 CKContainer.default().privateCloudDatabase.add(modifyOp)
 })
 
 
 sharingController.availablePermissions = [.allowReadWrite,
 .allowPrivate]
 sharingController.delegate = self
 self.present(sharingController, animated:true, completion:nil)
 */
