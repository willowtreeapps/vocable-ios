//
//  AccessibilityID+Shared+Keyboard.swift
//  Vocable
//
//  Created by Rudy Salas on 5/18/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.shared {
    public struct keyboard {
        public static let outputTextView: AccessibilityID = "keyboard-text-view"
        public static let favoriteButton: AccessibilityID = "favorite-button"
        public static let saveButton: AccessibilityID = "checkmark-save-button"
        private init() {}
    }
}
