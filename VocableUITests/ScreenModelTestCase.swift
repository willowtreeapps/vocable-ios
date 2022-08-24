//
//  ScreenModelTestCase.swift
//  VocableUITests
//
//  Created by Chris Stroud on 8/24/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

final class ScreenModelTestCase: BaseTest {

    override func setUp() {
        super.setUp()

        // All of these tests will start from
        // the settings screen
        RootScreen.Navigator()
            .navigateToSettingsScreen()
    }

    func testNavigationToCategoriesAndPhrases() {

        // Since we know we're on the settings screen,
        // use that navigator to hop to categories and phrases
        SettingsPage.Navigator()
            .navigateToCategoriesAndPhrases()
    }

    func testManualNavigationToCategoriesAndPhrases() {

        // Grab the element from the Settings page and
        // use it in a more conventional manner
        let cell = SettingsPage.query(\.categoriesAndPhrasesCell)
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Couldn't find cell")
        cell.tap()
        // assert we're on that screen somehow
    }
}
