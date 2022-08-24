//
//  AXElement+Settings+TimingSensitivity.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AXElement.settings {
    public enum timingAndSensitivity {
        public static let decreaseHoverTimeButton: AXElement = "timing-and-sensitivity-decrease-hover-time-button"
        public static let increaseHoverTimeButton: AXElement = "timing-and-sensitivity-increase-hover-time-button"
        public static let lowSensitivityButton: AXElement = "timing-and-sensitivity-low-sensitivity-button"
        public static let mediumSensitivityButton: AXElement = "timing-and-sensitivity-medium-sensitivity-button"
        public static let highSensitivityButton: AXElement = "timing-and-sensitivity-high-sensitivity-button"
        public static let hoverTimeLabel: AXElement = "timing-and-sensitivity-hover-time-label"
    }
}
