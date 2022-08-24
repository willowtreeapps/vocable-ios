//
//  RootScreen.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

struct RootScreen: ScreenModel {
    static let screenIdentifier: String = "vocable-root-screen"
    static let elements = Elements()
}

extension RootScreen {
    struct Elements {
        public let outputText: AXElement = "root-output-text"
        public let categoryBackButton: AXElement = "root-category-back-button"
        public let categoryForwardButton: AXElement = "root-category-forward-button"
        public let addPhraseButton: AXElement = "root-add-phrase-button"
        public let settingsButton: AXElement = "shared-settings-button"
    }
}
