//
//  AccessibilityID+Settings+SelectionMode.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.settings {
    public struct selectionMode {
        public static let headTrackingToggle: AccessibilityID = "selection-mode-head-tracking-toggle"
        public static let compactQwertyToggle: AccessibilityID = "selection-mode-compact-qwerty-toggle"
        public static let useBuiltInKeyboardToggle: AccessibilityID = "selection-mode-use-builtin-keyboard-toggle"
        private init() {}
    }
}
