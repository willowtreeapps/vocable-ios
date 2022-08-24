//
//  SettingsPage+ScreenModelNavigator.swift
//  Vocable
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

/// Defines the capability to navigate from
/// `SettingsPage` -> `CategoriesAndPhrasesScreen`
extension ScreenModelNavigator<SettingsPage> {
    @discardableResult
    public func navigateToCategoriesAndPhrases() -> ScreenModelNavigator<CategoriesAndPhrasesScreen> {
        performNavigation { page in
            page.query(\.categoriesAndPhrasesCell)
                .tap(afterWaitingForExistenceWithTimeout: 10)
        }
    }
}
