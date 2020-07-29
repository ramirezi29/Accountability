//
//  ReachabilityController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 2/19/20.
//  Copyright © 2020 ramcomw. All rights reserved.
//

import Foundation

class ReachabilityController {
    
    static let sharedReach = ReachabilityController()
    var reachability: Reachability?
    
    func activateReachability() {
        self.reachability = Reachability()
        
        reachability?.whenReachable = { reachability in
            DispatchQueue.main.async() {
                self.setOfflineView(false)
            }
        }
        
        reachability?.whenUnreachable = { reachability in
            DispatchQueue.main.async() {
                self.setOfflineView(true)
            }
        }
        do {
            try reachability?.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func setOfflineView(_ offline: Bool) {
        if offline {
            print("The user is off line")
        } else {
            print("The user is online")
        }
    }
}
