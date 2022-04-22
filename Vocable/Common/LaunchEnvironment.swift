//
//  LaunchEnvironment.swift
//  Vocable
//
//  Created by Chris Stroud on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

enum LaunchEnvironment {

    public enum Key: String {
        case overriddenPresets
    }

    static func value(for key: Key) -> String? {
        ProcessInfo.processInfo.environment[key.rawValue]
    }
}
