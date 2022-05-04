//
//  Analytics.swift
//  Vocable
//
//  Created by Chris Stroud on 5/3/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import Mixpanel

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

struct Analytics {

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
        return tokens.staging
    }()

    static let shared = Analytics()

    private init() {

        guard let token = Analytics.token else {
            print("No Mixpanel token found. Analytics will not be reported.")
            return
        }

        Mixpanel.initialize(token: token)
        print("Mixpanel initialized with token: \(token)")
    }
}
