//
//  EyeState.swift
//  EyeTrackingTest
//
//  Created by Kyle Ohanian on 6/26/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

enum EyeState {
    case closed
    case open
    
    static let closedThreshold = NSNumber(0.5)
    
    mutating func update(value: NSNumber) -> Bool {
        if value.floatValue > EyeState.closedThreshold.floatValue && self == .open {
            self = .closed
            return true
        } else if value.floatValue <= EyeState.closedThreshold.floatValue && self == .closed {
            self = .open
            return true
        }
        return false
    }
}
