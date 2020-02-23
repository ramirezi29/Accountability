//
//  textFieldExtension.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/26/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import UIKit


extension UITextField {
    
    //Needed to ensure the addressed entered in the search bar of the location detail is correct
    func toTrimmedString() -> String? {
        let ws = CharacterSet.whitespacesAndNewlines
        guard let trimmed = text?.trimmingCharacters(in: ws), !trimmed.isEmpty else {
            return nil
        }
        
        return trimmed
    }
}
