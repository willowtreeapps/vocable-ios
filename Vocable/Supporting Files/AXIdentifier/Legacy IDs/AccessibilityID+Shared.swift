//
//  AXElement+Shared.swift
//  Vocable
//
//  Created by Chris Stroud on 5/11/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

extension AXElement {
    public enum shared {
        public static let keyboardButton: AXElement = "shared-keyboard-button"
        public static let settingsButton: AXElement = "shared-settings-button"
        public static let backButton: AXElement = "shared-back-button"
        public static let dismissButton: AXElement = "shared-dismiss-button"
        public static let titleLabel: AXElement = "shared-title-label"
        public static let emptyStateAddPhraseButton: AXElement = "empty-state-addPhrase-button"
    }
}
