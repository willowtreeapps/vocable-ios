//
//  AccessibilityID+Settings.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID {
    public enum settings {
        public static let categoriesAndPhrasesCell: AXElement = "settings-categories-and-phrases-cell"
        public static let timingAndSensitivityCell: AXElement = "settings-timing-and-sensitivity-cell"
        public static let resetAppSettingsCell: AXElement = "settings-reset-app-settings-cell"
        public static let listeningModeCell: AXElement = "settings-listening-mode-cell"
        public static let selectionModeCell: AXElement = "settings-selection-mode-cell"
        public static let privacyPolicyCell: AXElement = "settings-privacy-policy-cell"
        public static let contactDevelopersCell: AXElement = "settings-contact-developers-cell"
    }
}
