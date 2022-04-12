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

    func testReorder() {
        settingsScreen.navigateToSettingsCategoryScreen()
        
        // Define the query that gives us the first category listed
        let currentFirstCategory = XCUIApplication().cells.allElementsBoundByIndex[0]
        // Define the query that gives us the second category listed
        let currentSecondCategory = XCUIApplication().cells.allElementsBoundByIndex[1]
        let originalFirstCategoryName = currentFirstCategory.label
        let originalSecondCategoryName = currentSecondCategory.label
        
        // Give me the first category, using our query, and confirm the state of the buttons
        XCTAssertFalse(currentFirstCategory.buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(currentFirstCategory.buttons[settingsScreen.categoryDownButton].isEnabled)
        
        // Give me the second category, using our query, and confirm the state of the buttons
        XCTAssertTrue(currentSecondCategory.buttons[settingsScreen.categoryUpButton].isEnabled)
        XCTAssertTrue(currentSecondCategory.buttons[settingsScreen.categoryDownButton].isEnabled)
        
        // Move the first category down one
        currentFirstCategory.buttons[settingsScreen.categoryDownButton].tap()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalSecondCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalFirstCategoryName)
        
        // Move the second category back up
        currentSecondCategory.buttons[settingsScreen.categoryUpButton].tap()
        
        // Using the query for the first category (i.e. top most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentFirstCategory.label, originalFirstCategoryName)
        
        // Using the query for the second category (i.e. second most cell in list) confirm the category name matches expectations
        XCTAssertEqual(currentSecondCategory.label, originalSecondCategoryName)
        
    }

}
