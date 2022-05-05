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

    private let mixPanel: MixpanelInstance

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
        let listeningMode = AppConfig.listeningMode
        cancellables = [mixPanel.registerSuperProperty("Listening Mode Enabled", using: listeningMode.$listeningModeEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("'Hey Vocable' Enabled", using: listeningMode.$hotwordEnabledPreference, on: queue),
                        mixPanel.registerSuperProperty("Head Tracking Enabled", using: AppConfig.$isHeadTrackingEnabled, on: queue)]
    }

    // MARK: - Events

    func appDidLaunch() {
        Mixpanel.mainInstance().track(event: "App Open")
    }
}

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
