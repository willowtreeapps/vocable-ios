//
//  XCUIApplication+LaunchConfiguration.swift
//  Vocable
//
//  Created by Chris Stroud on 4/25/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import Foundation
import XCTest

protocol XCTestAppConfigurable {
    func configure(_ app: XCUIApplication)
}

extension XCUIApplication {
    func configure(@ListBuilder<XCTestAppConfigurable> _ builder: () -> [XCTestAppConfigurable]) {
        builder().forEach { configurable in
            configurable.configure(self)
        }
    }
}
