//
//  AppConfig.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

struct AppConfig {
    static let showIncompleteFeatures: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
}
