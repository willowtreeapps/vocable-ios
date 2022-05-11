//
//  Analytics.swift
//  Vocable
//
//  Created by Chris Stroud on 5/3/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import Mixpanel
import Combine

private struct EnvironmentTokens {

    private static let infoPlistKeyStaging = "MIXPANEL_TOKEN_STAGING"
    private static let infoPlistKeyProduction = "MIXPANEL_TOKEN_PRODUCTION"

    let staging: String
    let production: String

    init?(infoDictionary dict: [String: Any]) {
        guard
            let staging = dict[EnvironmentTokens.infoPlistKeyStaging] as? String,
            let production = dict[EnvironmentTokens.infoPlistKeyProduction] as? String
        else {
            return nil
        }
        self.staging = staging
        self.production = production
    }
}

class Analytics {

    struct Event {
        let name: String
        var properties: Properties? = nil
    }

    private static let token: String? = {

        if let token = LaunchEnvironment.value(for: .mixpanelToken) {
            return token
        }
        guard
            let infoPlist = Bundle.main.infoDictionary,
            let tokens = EnvironmentTokens(infoDictionary: infoPlist)
        else {
            return nil
        }

        #if DEBUG
        // Debug builds will always point to staging unless we
        // specify otherwise via environment variable
        return tokens.staging
        #endif

        #warning("Change token selection to prod once everything is validated")
        return tokens.staging
    }()

    static let shared = Analytics()

    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "Analytics-Processing")

    private let mixPanel: MixpanelInstance

    private let listeningMode = AppConfig.listeningMode

    private init() {

        guard let token = Analytics.token else {
            print("No Mixpanel token found. Analytics will not be reported.")
            Mixpanel.initialize(token: "", trackAutomaticEvents: false)
            mixPanel = Mixpanel.mainInstance()
            return
        }

        Mixpanel.initialize(token: token, trackAutomaticEvents: false)
        print("Mixpanel initialized with token: \(token)")

        mixPanel = Mixpanel.mainInstance()
        registerSuperProperties()
    }

    // MARK: - Super Properties

    private func registerSuperProperties() {
        cancellables = [mixPanel.registerSuperProperty("Listening Mode Enabled", using: listeningMode.$listeningModeEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("'Hey Vocable' Enabled", using: listeningMode.$hotwordEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("Head Tracking Enabled", using: AppConfig.$isHeadTrackingEnabled, on: queue)]

        AppConfig.$cursorSensitivity
            .receive(on: queue)
            .sink { [weak self] sensitivity in
                self?.mixPanel.registerSuperProperties(["Cursor Sensitivity": sensitivity.analyticsDescription])
            }.store(in: &cancellables)

        AppConfig.$selectionHoldDuration
            .receive(on: queue)
            .sink { [weak self] hoverTime in
                self?.mixPanel.registerSuperProperties(["Hover Time": hoverTime.analyticsDescription])
            }.store(in: &cancellables)
    }

    // MARK: - Events

    func track(_ event: Event) {
        queue.async { [weak self] in
            self?.mixPanel.track(event: event.name, properties: event.properties)
        }
    }
}

// MARK: MixpanelInstance

private extension MixpanelInstance {
    func registerSuperProperty<P: Publisher>(
        _ name: String,
        using publisher: P,
        on queue: DispatchQueue
    ) -> AnyCancellable where P.Output: MixpanelType, P.Failure == Never {
        publisher
            .receive(on: queue)
            .sink { [weak self] value in
                self?.registerSuperProperties([name: value])
            }
    }
}

// MARK: Analytics Events

extension Analytics.Event {

    enum TranscriptionResult: String {
        case successful = "Successful Result"
        case soundsComplicated = "Sounds Complicated"

        var description: String { rawValue }
    }

    // MARK: App Lifecycle

    static let appOpened = Self(name: "App Opened")
    static let appBackgrounded = Self(name: "App Backgrounded")
    static let appClosed = Self(name: "App Closed")

    // MARK: Keyboard Phrase

    static let keyboardOpened = Self(name: "Keyboard Opened")
    static let keyboardPhraseSpoken = Self(name: "Keyboard Phrase Spoken")
    static let phraseFavorited = Self(name: "Keyboard Phrase Favorited")

    // MARK: Categories

    static let newCategoryCreated = Self(name: "New Category Created")

    static func presetCategoryRemoved(_ category: Category) -> Self {
        Self(name: "Preset Category Removed", properties: ["Category": category.name])
    }

    static func presetCategoryEdited(_ category: Category) -> Self {
        Self(name: "Preset Category Edited", properties: ["Category": category.name])
    }

    static func presetCategoryHidden(_ category: Category) -> Self {
        Self(name: "Preset Category Hidden", properties: ["Category": category.name])
    }

    // MARK: Phrases

    static let phraseCreated = Self(name: "New Phrase Created")

    static func presetPhraseEdited(_ utterance: String) -> Self {
        Self(name: "Preset Phrase Edited", properties: ["Phrase": utterance])
    }

    static func presetPhraseSelected(_ utterance: String) -> Self {
        Self(name: "Preset Phrase Selected", properties: ["Phrase": utterance])
    }

    // MARK: Listening Mode

    static func transcriptionSubmitted(_ transcription: String, result: [String]?) -> Self {
        let formattedResult = result?.joined(separator: ", ")
        return Self(name: "Phrase Submitted to Developers",
             properties: [
                "Transcription": transcription,
                "Result": formattedResult ?? "Sounds Complicated",
                "Transcription Character Count": transcription.count
             ])
    }

    // MARK: Settings

    static let hoverTimeChanged = Self(name: "Hover Time Settings Changed")
    static let cursorSensitivityChanged = Self(name: "Cursor Sensitivity Changed")

    static let listeningModeChanged = Self(name: "Listening Mode Settings Changed")
    static let heyVocableModeChanged = Self(name: "'Hey Vocable' Settings Changed")

    static let headingTrackingChanged = Self(name: "Head Tracking Settings Changed")
}
