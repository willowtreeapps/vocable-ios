//
//  AXElement+Shared+Alert.swift
//  Vocable
//
//  Created by Canan Arikan on 5/27/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AXElement.shared {
    public enum alert {
        public static let continueButton: AXElement = "alert-button-continue-editing"
        public static let discardButton: AXElement = "alert-button-discard-changes"
        public static let deleteButton: AXElement = "alert-button-delete"
        public static let cancelButton: AXElement = "alert-button-cancel"
        public static let createDuplicateButton: AXElement = "alert-button-create-duplicate"
        public static let messageLabel: AXElement = "alert-message"
    }
}
