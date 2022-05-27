//
//  AccessibilityID+Shared+Alert.swift
//  Vocable
//
//  Created by Canan Arikan on 5/27/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AccessibilityID.shared {
    public struct alert {
        public static let continueButton: AccessibilityID = "alert-button-continue-editing"
        public static let discardButton: AccessibilityID = "alert-button-discard-changes"
        public static let deleteButton: AccessibilityID = "alert-button-delete"
        public static let cancelButton: AccessibilityID = "alert-button-cancel"
        private init() {}
    }
}
