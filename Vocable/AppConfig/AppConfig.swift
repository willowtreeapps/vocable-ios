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
    static let isHotdogModeEnabled: UserDefaultsKey = "isHotdogModeEnabled"
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

    @PublishedDefault(.isCompactQWERTYKeyboardEnabled)
    static var isCompactQWERTYKeyboardEnabled: Bool = false
    
    @PublishedDefault(.selectedVoiceIdentifier)
    static var selectedVoiceIdentifier: String? = .none

    @PublishedDefault(.isHotdogModeEnabled)
    static var isHotdogModeEnabled: Bool = false
}
