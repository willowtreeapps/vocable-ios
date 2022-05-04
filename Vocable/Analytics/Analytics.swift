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

    private init() {

        guard let token = Analytics.token else {
            print("No Mixpanel token found. Analytics will not be reported.")
            Mixpanel.initialize(token: "", trackAutomaticEvents: false)
            return
        }

        Mixpanel.initialize(token: token, trackAutomaticEvents: false)
        print("Mixpanel initialized with token: \(token)")

        registerSuperProperties()
    }

    // MARK: - Super Properties

    private func registerSuperProperties() {
        let listeningMode = AppConfig.listeningMode
        register(superProperty: "Listening Mode Enabled", using: listeningMode.$listeningModeEnabledPreference)
        register(superProperty: "'Hey Vocable' Enabled", using: listeningMode.$hotwordEnabledPreference)
        register(superProperty: "Head Tracking Enabled", using: AppConfig.$isHeadTrackingEnabled)
    }

    private func register(superProperty: String, using publisher: CurrentValueSubject<Bool, Never>) {
        register(superProperty: superProperty, using: publisher.eraseToAnyPublisher())
    }

    private func register(superProperty: String, using publisher: AnyPublisher<Bool, Never>) {
        publisher
            .receive(on: queue)
            .sink { newValue in
                Mixpanel.mainInstance().registerSuperProperties([superProperty: newValue])
            }.store(in: &cancellables)
    }

    // MARK: - Events

    func appDidLaunch() {
        Mixpanel.mainInstance().track(event: "App Open")
    }
}
