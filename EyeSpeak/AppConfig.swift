//
//  AppConfig.swift
//  EyeSpeak
//
//  Created by Patrick Gatewood on 2/7/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation
import Combine

struct AppConfig {
    static let showPIDTunerDebugMenu: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static var isHeadTrackingEnabled = UserDefaults.standard.value(forKey: "isHeadTrackingEnabled") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isHeadTrackingEnabled, forKey: "isHeadTrackingEnabled")
            headTrackingValueSubject.send(isHeadTrackingEnabled)
            if !isHeadTrackingEnabled {
                NotificationCenter.default.post(name: .headTrackingDisabled, object: nil)
            }
        }
    }
    
    static let headTrackingValueSubject = CurrentValueSubject<Bool, Never>(isHeadTrackingEnabled)
}
