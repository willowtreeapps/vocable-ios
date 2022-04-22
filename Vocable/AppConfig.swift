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

    static let isListeningModeEnabled: UserDefaultsKey = "isListeningModeEnabled"
    static let isHotWordPermitted: UserDefaultsKey = "isHotWordPermitted"
    static let sensitivitySetting: UserDefaultsKey = "sensitivitySetting"
    static let dwellDuration: UserDefaultsKey = "dwellDuration"
    static let isHeadTrackingEnabled: UserDefaultsKey = "isHeadTrackingEnabled"
    static let listeningModeFeatureFlagEnabled: UserDefaultsKey = "listeningModeFeatureFlagEnabled"
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

    @PublishedDefault(.isHotWordPermitted)
    static var isHotWordPermitted: Bool = true

    @PublishedDefault(.isListeningModeEnabled)
    static var isListeningModeEnabled: Bool = isListeningModeSupported

    static var isListeningModeSupported: Bool {

        // Listening mode is currently only supported for English
        if Locale(identifier: activePreferredLanguageCode).languageCode != "en" {
            return false
        }

        // ML models currently rely on CoreML features introduced in iOS 14
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }

    static let defaultLanguageCode = "en"
    static var activePreferredLanguageCode: String {
        return Locale.preferredLanguages.first ?? defaultLanguageCode
    }

    @PublishedDefault(.listeningModeFeatureFlagEnabled)
    static var listeningModeFeatureFlagEnabled: Bool = false
}
