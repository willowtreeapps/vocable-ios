//
//  AnimationHelpers.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 5/24/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import Foundation

enum AnimatingState {
    case idle
    case shrinking
    case expanding
    case expanded
    case cancelled
    
    var isGazing: Bool {
        return self == .expanding || self == .expanded
    }
}
