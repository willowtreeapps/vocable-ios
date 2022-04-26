//
//  LaunchArguments.swift
//  Vocable
//
//  Created by Jesse Morgan on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation

public enum LaunchArguments {

    public enum Key: String {
        case resetAppDataOnLaunch
        case enableListeningMode
    }

    static func contains(_ key: Key) -> Bool {
        CommandLine.customArguments.contains(key)
    }
}

fileprivate extension CommandLine {

    static var customArguments: [LaunchArguments.Key] {
        arguments.compactMap(LaunchArguments.Key.init)
    }
}
