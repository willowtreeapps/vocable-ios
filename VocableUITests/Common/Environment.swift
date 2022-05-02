//
//  Environment.swift
//  Vocable
//
//  Created by Chris Stroud on 4/25/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

protocol LaunchEnvironmentEncodable {
    func launchEnvironmentValue() -> String
}

struct Environment: XCTestAppConfigurable {

    private let key: LaunchEnvironment.Key
    private let value: String

    init(_ key: LaunchEnvironment.Key, value: String) {
        self.key = key
        self.value = value
    }

    init<T>(_ key: LaunchEnvironment.Key, value: () -> T) where T: LaunchEnvironmentEncodable {
        self.key = key
        self.value = value().launchEnvironmentValue()
    }

    func configure(_ app: XCUIApplication) {
        app.launchEnvironment[key.rawValue] = value
    }
}
