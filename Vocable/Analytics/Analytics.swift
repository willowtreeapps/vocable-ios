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
        listenForSettingsChanges()
    }

    // MARK: - Super Properties

    private func registerSuperProperties() {
        cancellables = [mixPanel.registerSuperProperty("Listening Mode Enabled", using: listeningMode.$listeningModeEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("'Hey Vocable' Enabled", using: listeningMode.$hotwordEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("Head Tracking Enabled", using: AppConfig.$isHeadTrackingEnabled, on: queue)]
    }

    private func listenForSettingsChanges() {
        track(.listeningModeChanged, onUpdateOf: listeningMode.$listeningModeEnabledPreference)
        track(.heyVocableModeChanged, onUpdateOf: listeningMode.$hotwordEnabledPreference)
        track(.headingTrackingChanged, onUpdateOf: AppConfig.$isHeadTrackingEnabled)
    }

    // MARK: - Events

    func track(_ event: Event) {
        queue.async { [weak self] in
            self?.mixPanel.track(event: event.name, properties: event.properties)
        }
    }

    private func track<P: Publisher>(_ event: Event, onUpdateOf publisher: P) where P.Failure == Never {
        publisher
            .receive(on: queue)
            .sink { [weak self] _ in
                self?.track(event)
            }.store(in: &cancellables)
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

    static let appOpen = Self(name: "App Open")

    static let headingTrackingChanged = Self(name: "Head Tracking Settings Changed")
    static let listeningModeChanged = Self(name: "Listening Mode Settings Changed")
    static let heyVocableModeChanged = Self(name: "'Hey Vocable' Settings Changed")

    static func transcriptionProcessed(result: TranscriptionResult) -> Self {
        Self(name: "Listen Mode Phrase Processed", properties: ["Result Type": result.description])
    }

    static func transcriptionSubmitted(_ transcription: String, result: [String]?) -> Self {
        let formattedResult = result?.joined(separator: ", ")
        return Self(name: "Phrase Submitted for Review",
             properties: [
                "Transcription": transcription,
                "Result": formattedResult ?? "Sounds Complicated",
                "Transcription Character Count": transcription.count
             ])
    }
}
