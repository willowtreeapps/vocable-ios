//
//  SettingsPage.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

struct SettingsPage: ScreenModel, NavigationPage {
    static let screenIdentifier: String = "vocable-settings-screen"
    static let elements = Elements()
}

extension SettingsPage {
    struct Elements {
        public let categoriesAndPhrasesCell: AXElement = "settings-categories-and-phrases-cell"
        public let timingAndSensitivityCell: AXElement = "settings-timing-and-sensitivity-cell"
        public let resetAppSettingsCell: AXElement = "settings-reset-app-settings-cell"
        public let listeningModeCell: AXElement = "settings-listening-mode-cell"
        public let selectionModeCell: AXElement = "settings-selection-mode-cell"
        public let privacyPolicyCell: AXElement = "settings-privacy-policy-cell"
        public let contactDevelopersCell: AXElement = "settings-contact-developers-cell"
    }
}
