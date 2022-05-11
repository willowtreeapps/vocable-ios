//
//  AccessibilityID+Settings+TimingSensitivity.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.settings {
    public struct timingAndSensitivity {
        public static let decreaseHoverTimeButton: AccessibilityID = "settings-timing-and-sensitivity-decrease-hover-time-button"
        public static let increaseHoverTimeButton: AccessibilityID = "settings-timing-and-sensitivity-increase-hover-time-button"
        public static let lowSensitivityButton: AccessibilityID = "settings-timing-and-sensitivity-low-sensitivity-button"
        public static let mediumSensitivityButton: AccessibilityID = "settings-timing-and-sensitivity-medium-sensitivity-button"
        public static let highSensitivityButton: AccessibilityID = "settings-timing-and-sensitivity-high-sensitivity-button"
        private init() {}
    }
}
