//
//  Sobriety.swift
//  Triggers
//
//  Created by Ivan Ramirez on 8/30/20.
//  Copyright © 2020 ramcomw. All rights reserved.
//

import Foundation
import CloudKit

class Sobriety {
    
    var sobrietyDate: Date
    var ckRecordID: CKRecord.ID
    var userSobrietyReference: CKRecord.Reference?
    
    init(sobrietyDate: Date, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.sobrietyDate = sobrietyDate
        self.ckRecordID = ckRecordID
        
        if let currentUserID = UserController.shared.loggedInUser?.ckRecordID {
            self.userSobrietyReference = CKRecord.Reference(recordID: currentUserID, action: .deleteSelf)
        }
    }
    
    var sobrietyDateAsString: String {
         return DateFormatter.localizedString(from: sobrietyDate, dateStyle: .short, timeStyle: .short)
    }

            convenience init?(ckRecord: CKRecord) {
                
                guard let sobrietyDate = ckRecord[SobrietyConstants.sobrietyDateKey] as? Date
                    
                    else { return nil }
                
               let userSobrietyReference = ckRecord[SobrietyConstants.sobreityRefKey] as? CKRecord.Reference
                    
                self.init(sobrietyDate: sobrietyDate, ckRecordID: ckRecord.recordID)
                    
                    self.userSobrietyReference = userSobrietyReference
            }
        }

extension CKRecord {
    convenience init(sobriety: Sobriety) {
        self.init(recordType: SobrietyConstants.sobrietyTypeKey, recordID: sobriety.ckRecordID)
        
        self.setValue(sobriety.sobrietyDate, forKey: SobrietyConstants.sobrietyDateKey)
        
        self.setValue(sobriety.userSobrietyReference, forKey: SobrietyConstants.sobreityRefKey)
    }
}

extension Sobriety: Equatable {
    static func == (lhs: Sobriety, rhs: Sobriety) -> Bool {
        if lhs.ckRecordID != rhs.ckRecordID { return false }
        
        return true
    }
}
