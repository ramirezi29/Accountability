//
//  NetworkingError.swift
//  Triggers
//
//  Created by Ivan Ramirez on 12/17/18.
//  Copyright © 2018 ramcomw. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case badBaseURL(String)
    case badBuiltURL(String)
    case forwardedError(Error)
    case invalidData(String)
}

