//
//  AppConfig.swift
//  Vocable AAC
//
//  Created by Patrick Gatewood on 2/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine
import ARKit

extension UserDefaultsKey {

    static let listeningModeEnabledPreference: UserDefaultsKey = "listeningModeEnabledPreference"
    static let listeningModeHotWordEnabledPreference: UserDefaultsKey = "listeningModeHotWordEnabledPreference"
    static let sensitivitySetting: UserDefaultsKey = "sensitivitySetting"
    static let dwellDuration: UserDefaultsKey = "dwellDuration"
    static let isHeadTrackingEnabled: UserDefaultsKey = "isHeadTrackingEnabled"
    static let isCompactPortraitQWERTYKeyboardEnabled: UserDefaultsKey = "isCompactPortraitQWERTYKeyboardEnabled"
}

struct AppConfig {

    static let showDebugOptions: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    @PublishedDefault(.isHeadTrackingEnabled)
    static var isHeadTrackingEnabled: Bool = AppConfig.isHeadTrackingSupported
    static var isHeadTrackingSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }

    @PublishedDefault(.dwellDuration)
    static var selectionHoldDuration: TimeInterval = 1

    @PublishedDefault(.sensitivitySetting)
    static var cursorSensitivity: CursorSensitivity = CursorSensitivity.medium

    static let defaultLanguageCode = "en"
    static var activePreferredLanguageCode: String {
        return Locale.preferredLanguages.first ?? defaultLanguageCode
    }

    static let listeningMode = ListenModeFeatureConfiguration.shared

    @PublishedDefault(.isCompactPortraitQWERTYKeyboardEnabled)
    static var isCompactQWERTYKeyboardEnabled: Bool = false
}
