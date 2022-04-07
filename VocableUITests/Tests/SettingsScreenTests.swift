//
//  SettingsScreenTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/24/20.
//  Updated by Canan Arikan and Rudy Salas on 03/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreenTests: BaseTest {

    func testHideShowToggle() {
        let category = "Environment"

        settingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(settingsScreen.locateCategoryCell(category).element.exists)

        // Verify that when the category is hidden, up and down buttons are disabled.
        settingsScreen.openCategorySettings(category: category)
        settingsScreen.showCategoryButton.tap()
        settingsScreen.leaveCategoryDetailButton.tap()
        
        let hiddenCategory = settingsScreen.locateCategoryCell(category)
        XCTAssertFalse(hiddenCategory.buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[settingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.element.isEnabled)

        // Verify that when the category is shown, up and down buttons are enabled.
        settingsScreen.openCategorySettings(category: category)
        settingsScreen.showCategoryButton.tap()
        settingsScreen.leaveCategoryDetailButton.tap()
        
        let shownCategory = settingsScreen.locateCategoryCell(category)
        XCTAssertTrue(shownCategory.buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(shownCategory.buttons[settingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(shownCategory.element.isEnabled)
    }

    // We are disabling this test for now, it will be updated after the issue is completed: https://github.com/willowtreeapps/vocable-ios/issues/492
    func testReorder() {
        let generalCategoryText = "General"
        let basicNeedsCategoryText = "Basic Needs"
        
        let expectedGeneralCategoryText = "General"
        let expectedbasicNeedsCategoryText = "Basic Needs"

        settingsScreen.navigateToSettingsCategoryScreen()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

        settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).buttons[settingsScreen.categoryDownButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: expectedbasicNeedsCategoryText).element.exists)
        
        settingsScreen.otherElements.containing(.staticText, identifier: expectedGeneralCategoryText).buttons[settingsScreen.categoryUpButton].tap()
        
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: generalCategoryText).element.exists)
        XCTAssert(settingsScreen.otherElements.containing(.staticText, identifier: basicNeedsCategoryText).element.exists)

    }

}
