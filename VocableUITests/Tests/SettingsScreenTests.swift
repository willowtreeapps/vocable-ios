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

        SettingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(category).element.exists)

        // Verify that when the category is hidden, up and down buttons are disabled.
        SettingsScreen.openCategorySettings(category: category)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        let hiddenCategory = SettingsScreen.locateCategoryCell(category)
        XCTAssertFalse(hiddenCategory.buttons[SettingsScreen.categoryUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[SettingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.element.isEnabled)

        // Verify that when the category is shown, up and down buttons are enabled.
        SettingsScreen.openCategorySettings(category: category)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        let shownCategory = SettingsScreen.locateCategoryCell(category)
        XCTAssertTrue(shownCategory.buttons[SettingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(shownCategory.buttons[SettingsScreen.categoryDownButton].isEnabled)
        XCTAssertTrue(shownCategory.element.isEnabled)
    }

    func testReorder() {
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Define the query that gives us the first category listed
        let currentFirstCategory = XCUIApplication().cells.allElementsBoundByIndex[0]
        // Define the query that gives us the second category listed
        let currentSecondCategory = XCUIApplication().cells.allElementsBoundByIndex[1]
        let originalFirstCategoryName = currentFirstCategory.label
        let originalSecondCategoryName = currentSecondCategory.label
        
        // Give me the first category, using our query, and confirm the state of the buttons
        XCTAssertFalse(currentFirstCategory.buttons[SettingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(currentFirstCategory.buttons[SettingsScreen.categoryDownButton].isEnabled)
        
        // Give me the second category, using our query, and confirm the state of the buttons
        XCTAssertTrue(currentSecondCategory.buttons[SettingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(currentSecondCategory.buttons[SettingsScreen.categoryDownButton].isEnabled)
        
        // Move the first category down one
        currentFirstCategory.buttons[SettingsScreen.categoryDownButton].tap()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalSecondCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalFirstCategoryName)
        
        // Move the second category back up
        currentSecondCategory.buttons[SettingsScreen.categoryUpButton].tap()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalFirstCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalSecondCategoryName)
    }
}
