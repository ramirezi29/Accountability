//
//  Note.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/19/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class Note {
    
    var title: String
    var textBody: String?
    var timeStamp: Date
    let ckRecordID: CKRecord.ID
    var folderReference: CKRecord.Reference?
    
    init(title: String, textBody: String, folderReference: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.title = title
        self.timeStamp = Date()
        self.textBody = textBody
        self.ckRecordID = ckRecordID
        self.folderReference = folderReference
    }
    
    var timeStampAsString: String {
        return DateFormatter.localizedString(from: timeStamp, dateStyle: .short, timeStyle: .none)
    }
    
    // NOTE: - Create a model object fromR a CKRecord - Fetch
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[NoteConstants.titleKey] as? String,
            
            let textBody = ckRecord[NoteConstants.textBodyKey] as? String,
            
            let folderReference = ckRecord[NoteConstants.folderReferenceKey] as? CKRecord.Reference else { return nil }
        
        self.init(title: title, textBody: textBody, folderReference: folderReference)
    }
}

// NOTE: - Create a CKRecord using our model object - Push
extension CKRecord {
    convenience init(note: Note) {
        
        self.init(recordType: NoteConstants.NoteTypeKey, recordID: note.ckRecordID)
        self.setValue(note.title, forKey: NoteConstants.titleKey)
        self.setValue(note.textBody, forKey: NoteConstants.textBodyKey)
        self.setValue(note.timeStamp, forKey: NoteConstants.timeStampKey)
        self.setValue(note.folderReference, forKey: NoteConstants.folderReferenceKey)
    }
}

extension Note: Equatable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        
        return true
    }
}
