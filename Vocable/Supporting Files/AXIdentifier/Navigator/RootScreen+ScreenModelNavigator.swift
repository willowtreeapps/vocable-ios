//
//  RootScreen+ScreenModelNavigator.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

/// Defines the capability to navigate from
/// `RootScreen` -> `SettingsScreen`
extension ScreenModelNavigator<RootScreen> {
    @discardableResult
    public func navigateToSettingsScreen(file: StaticString = #file,
                                         line: UInt = #line) -> ScreenModelNavigator<SettingsPage> {
        performNavigation(file: file, line: line) { page in
            let button = page.query(\.settingsButton)
            _ = button.waitForExistence(timeout: 10)
            button.tap()
        }
    }
}

