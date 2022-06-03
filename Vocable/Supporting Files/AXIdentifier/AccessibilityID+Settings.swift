//
//  AccessibilityID+Settings.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID {
    public struct settings {
        public static let categoriesAndPhrasesCell: AccessibilityID = "settings-categories-and-phrases-cell"
        public static let timingAndSensitivityCell: AccessibilityID = "settings-timing-and-sensitivity-cell"
        public static let resetAppSettingsCell: AccessibilityID = "settings-reset-app-settings-cell"
        public static let listeningModeCell: AccessibilityID = "settings-listening-mode-cell"
        public static let selectionModeCell: AccessibilityID = "settings-selection-mode-cell"
        public static let privacyPolicyCell: AccessibilityID = "settings-privacy-policy-cell"
        public static let contactDevelopersCell: AccessibilityID = "settings-contact-developers-cell"
        private init() {}
    }
}
