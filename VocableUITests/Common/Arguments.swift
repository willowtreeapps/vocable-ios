//
//  LaunchArguments+StringArray.swift
//  VocableUITests
//
//  Created by Jesse Morgan on 4/22/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

struct Arguments: XCTestAppConfigurable {

    private let keys: [LaunchArguments.Key]

    init(_ keys: LaunchArguments.Key...) {
        self.keys = keys
    }

    func configure(_ app: XCUIApplication) {
        app.launchArguments = keys.map(\.rawValue)
    }
}


