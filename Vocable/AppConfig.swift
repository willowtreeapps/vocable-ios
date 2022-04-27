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
import CoreData

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

    static let defaultLanguageCode = "en"
    static var activePreferredLanguageCode: String {
        return Locale.preferredLanguages.first ?? defaultLanguageCode
    }

    static let listeningMode = ListenModeFeatureConfiguration()
}

final class ListenModeFeatureConfiguration {

    // Whether the feature is active or not
    // Not exposed to consumers, but used for dynamically
    // determining whether the feature is enabled
    @PublishedDefault(.listeningModeFeatureFlagEnabled)
    private(set) var isFeatureFlagEnabled: Bool = false

    // Whether listening mode is allowed to function
    // This can vary based on the feature flag AND the user preference
    @PublishedValue
    private(set) var isEnabled: Bool = true

    // Whether the hotword feature is allowed to function
    // This can vary based on the feature flag AND the user preference
    @PublishedValue
    private(set) var isHotWordEnabled: Bool = true

    // The user's preference for whether the overall listening mode feature is enabled
    @PublishedDefault(.isListeningModeEnabled)
    var listeningModeEnabledPreference: Bool = ListenModeFeatureConfiguration.deviceSupportsListeningMode

    // The user's preference for whether the hotword feature is enabled
    @PublishedDefault(.isHotWordPermitted)
    var hotwordEnabledPreference: Bool = true

    private static var deviceSupportsListeningMode: Bool {

        guard SpeechRecognitionController.deviceSupportsSpeech else {
            return false
        }

        // Listening mode is currently only supported for English
        if Locale(identifier: AppConfig.activePreferredLanguageCode).languageCode != "en" {
            return false
        }

        // ML models currently rely on CoreML features introduced in iOS 14
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }

    private var cancellables = Set<AnyCancellable>()

    fileprivate init() {

        if LaunchArguments.contains(.enableListeningMode) {
            isFeatureFlagEnabled = true
        }
        
        Publishers.CombineLatest3($isFeatureFlagEnabled, $listeningModeEnabledPreference, $hotwordEnabledPreference)
            .removeDuplicates { lhs, rhs in
                lhs.0 == rhs.0 &&
                lhs.1 == rhs.1 &&
                lhs.2 == rhs.2
            }
            .sink { [weak self] (isFlagEnabled, isListeningModeEnabled, isHotWordEnabled) in
                let modeEnabled = isFlagEnabled && isListeningModeEnabled && ListenModeFeatureConfiguration.deviceSupportsListeningMode
                let hotwordEnabled = modeEnabled && isHotWordEnabled
                self?.isEnabled = modeEnabled
                self?.isHotWordEnabled = hotwordEnabled
            }.store(in: &cancellables)

        $isEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateCategoryOrdinalsAfterVisibilityChange()
            }.store(in: &cancellables)
    }

    private func updateCategoryOrdinalsAfterVisibilityChange() {
        let ctx = NSPersistentContainer.shared.newBackgroundContext()
        ctx.perform {
            do {
                try Category.updateAllOrdinalValues(in: ctx)
                try ctx.save()
            } catch {
                print("Failed to update ordinals: \(error)")
            }
        }
    }
}
