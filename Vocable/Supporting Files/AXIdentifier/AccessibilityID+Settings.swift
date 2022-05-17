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
        public static let closeSettingsButton: AccessibilityID = "settings-close-settings-button"
        public static let navBarBackButton: AccessibilityID = "settings-nav-bar-back-button"
        public static let categoriesAndPhrasesButton: AccessibilityID = "settings-categories-and-phrases-button"
        public static let timingAndSensitivityButton: AccessibilityID = "settings-timing-and-sensitivity-button"
        public static let resetAppSettingsButton: AccessibilityID = "settings-reset-app-settings-button"
        public static let selectionModeButton: AccessibilityID = "settings-selection-mode-button"
        public static let tuneCursorButton: AccessibilityID = "settings-tune-cursor-button"
        public static let privacyPolicyButton: AccessibilityID = "settings-privacy-policy-button"
        public static let contactDevelopersButton: AccessibilityID = "settings-contact-developers-button"
        private init() {}
    }
}
