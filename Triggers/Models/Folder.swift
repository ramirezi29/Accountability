//
//  Folder.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/29/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class Folder {
    
    var folderTitle: String
    var timeStamp: Date
    let ckRecordID: CKRecord.ID
    var userFolderReference: CKRecord.Reference?
    
    var notes: [Note] = []
    
    init(folderTitle: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.folderTitle = folderTitle
        self.timeStamp = Date()
        self.ckRecordID = ckRecordID
        
        if let currentID = UserController.shared.loggedInUser?.ckRecordID {
            self.userFolderReference = CKRecord.Reference(recordID: currentID, action: .deleteSelf)
        }
    }
    
    var timeStampAsString: String {
        return DateFormatter.localizedString(from: timeStamp, dateStyle: .short, timeStyle: .none)
    }
    
    // NOTE: - Fech ckRecord
    convenience init?(ckRecord: CKRecord) {
        
        guard let folderTitle = ckRecord[FolderConstants.folderTitleKey] as? String else { return nil }
        
        let userFolderReference = ckRecord[FolderConstants.userFolderReferenceKey] as? CKRecord.Reference
        
        self.init(folderTitle: folderTitle, ckRecordID: ckRecord.recordID)
        
        self.userFolderReference = userFolderReference
    }
}

// NOTE: - Push

extension CKRecord {
    convenience init(folder: Folder) {
        
        self.init(recordType: FolderConstants.FolderTypeKey, recordID: folder.ckRecordID)
        self.setValue(folder.folderTitle, forKey: FolderConstants.folderTitleKey)
        self.setValue(folder.timeStamp, forKey: FolderConstants.timeStampKey)
        self.setValue(folder.userFolderReference, forKey: FolderConstants.userFolderReferenceKey)
    }
}

extension Folder: Equatable {
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        
        return true
    }
}
