//
//  AccessibilityID+Shared.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID {
    public struct shared {
        public static let keyboardButton: AccessibilityID = "shared-keyboard-button"
        public static let settingsButton: AccessibilityID = "shared-settings-button"
        public static let backButton: AccessibilityID = "shared-back-button"
        public static let dismissButton: AccessibilityID = "shared-dismiss-button"
        public static let titleLabel: AccessibilityID = "shared-title-label"
        public static let emptyStateAddPhraseButton: AccessibilityID = "empty-state-addPhrase-button"
        private init() {}
    }
}
