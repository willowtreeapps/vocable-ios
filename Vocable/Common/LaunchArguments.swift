//
//  LaunchArguments.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

public struct LaunchArguments {

    public enum Key: String {
        case resetAppDataOnLaunch
        case enableListeningMode
        case disableAnimations
    }

    static func contains(_ key: Key) -> Bool {
        CommandLine
            .arguments
            .compactMap(LaunchArguments.Key.init)
            .contains(key)
    }

    let keys: [Key]

    private init() {
        keys = []
    }
}
