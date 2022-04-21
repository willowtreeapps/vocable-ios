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

struct AppConfig {

    static let showDebugOptions: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    @PublishedDefault(key: "isHeadTrackingEnabled", defaultValue: AppConfig.isHeadTrackingSupported)
    static var isHeadTrackingEnabled: Bool
    static var isHeadTrackingSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }

    @PublishedDefault(key: "dwellDuration", defaultValue: 1)
    static var selectionHoldDuration: TimeInterval

    @PublishedDefault(key: "sensitivitySetting", defaultValue: CursorSensitivity.medium)
    static var cursorSensitivity: CursorSensitivity

    @PublishedDefault(key: "isHotWordPermitted", defaultValue: true)
    static var isHotWordPermitted: Bool

    @PublishedDefault(key: "isListeningModeEnabled", defaultValue: isListeningModeSupported)
    static var isListeningModeEnabled: Bool

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

    static let isListenModeEnabled = false
}
