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
import AVFoundation

extension UserDefaultsKey {

    static let listeningModeEnabledPreference: UserDefaultsKey = "listeningModeEnabledPreference"
    static let listeningModeSmartAssistEnabledPreference: UserDefaultsKey = "listeningModeSmartAssistEnabledPreference"
    static let listeningModeHotWordEnabledPreference: UserDefaultsKey = "listeningModeHotWordEnabledPreference"
    static let sensitivitySetting: UserDefaultsKey = "sensitivitySetting"
    static let dwellDuration: UserDefaultsKey = "dwellDuration"
    static let isHeadTrackingEnabled: UserDefaultsKey = "isHeadTrackingEnabled"
    static let isCompactQWERTYKeyboardEnabled: UserDefaultsKey = "isCompactQWERTYKeyboardEnabled"
    static let selectedVoiceIdentifier: UserDefaultsKey = "selectedVoiceIdentifier"
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

    /// Personal Voice is supported when the device and OS support it (e.g. iPhone 12+, iOS 17+).
    /// Note: `personalVoiceAuthorizationStatus` only returns `.unsupported` in the Simulator or on
    /// non-iPhone platforms — NOT on older iPhones (e.g. iPhone 11) running iOS 17. Hardware support
    /// is detected separately via the device model identifier.
    static var isPersonalVoiceSupported: Bool {
        if #available(iOS 17.0, *) {
            let status = AVSpeechSynthesizer.personalVoiceAuthorizationStatus
            if status == .unsupported {
                return false
            }
            return isPersonalVoiceHardwareSupported
        }
        return false
    }

    /// Returns `true` if the device hardware supports Personal Voice (iPhone 12 or later).
    /// Personal Voice model identifiers start at "iPhone13,x" (iPhone 12). The Simulator and
    /// non-iPhone platforms are already handled by the `.unsupported` auth status check above.
    private static var isPersonalVoiceHardwareSupported: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        guard machine.hasPrefix("iPhone") else { return true }
        let version = machine.dropFirst("iPhone".count)
        guard let major = version.split(separator: ",").first.flatMap({ Int($0) }) else { return true }
        // iPhone 12 starts at "iPhone13,x"; iPhone 11 Pro Max is "iPhone12,5"
        return major >= 13
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

    @PublishedDefault(.isCompactQWERTYKeyboardEnabled)
    static var isCompactQWERTYKeyboardEnabled: Bool = false
    
    @PublishedDefault(.selectedVoiceIdentifier)
    static var selectedVoiceIdentifier: String? = .none
}
