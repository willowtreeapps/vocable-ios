//
//  ListeningModeConfig.swift
//  Vocable
//
//  Created by Chris Stroud on 4/27/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import Combine
import CoreData

final class ListenModeFeatureConfiguration: ObservableObject {
    
    static let shared = ListenModeFeatureConfiguration()

    // Whether the feature is active or not
    // Not exposed to consumers, but used for dynamically
    // determining whether the feature is enabled
    @PublishedValue
    var isFeatureFlagEnabled: Bool = true {
        willSet {
            self.objectWillChange.send()
        }
    }

    // Whether listening mode is allowed to function
    // This can vary based on the feature flag AND the user preference
    @PublishedValue
    private(set) var isEnabled: Bool = true

    // Whether the hotword feature is allowed to function
    // This can vary based on the feature flag AND the user preference
    @PublishedValue
    private(set) var isHotWordEnabled: Bool = true

    // The user's preference for whether the overall listening mode feature is enabled
    @PublishedDefault(.listeningModeEnabledPreference)
    var listeningModeEnabledPreference: Bool = ListenModeFeatureConfiguration.deviceSupportsListeningMode()

    // The user's preference for whether the hotword feature is enabled
    @PublishedDefault(.listeningModeHotWordEnabledPreference)
    var hotwordEnabledPreference: Bool = true

    private var cancellables = Set<AnyCancellable>()

    private init() {

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
                let modeEnabled = isFlagEnabled && isListeningModeEnabled && ListenModeFeatureConfiguration.deviceSupportsListeningMode()
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
        let context = NSPersistentContainer.shared.newBackgroundContext()
        context.perform {
            do {
                try Category.updateAllOrdinalValues(in: context)
                try context.save()
            } catch {
                print("Failed to update ordinals: \(error)")
            }
        }
    }

    private static func deviceSupportsListeningMode() -> Bool {

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
}
