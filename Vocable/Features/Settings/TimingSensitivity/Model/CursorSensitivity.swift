//
//  Sensitivity.swift
//  Vocable AAC
//
//  Created by Jesse Morgan on 3/30/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

enum CursorSensitivity: Int, Codable {
    
    // The minimum/maximum values to scale how quickly the cursor moves around the screen
    var range: ClosedRange<Double> {
        switch self {
        case .low:
            return (2.0 ... 4.0)
        case .medium:
            return (3.0 ... 5.0)
        case .high:
            return (4.0 ... 6.5)
        }
    }
    
    case low
    case medium
    case high
}
