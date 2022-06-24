//
//  CustomCategoryAppRestartTests.swift
//  VocableUITests
//
//  Created by Canan Arikan on 6/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest
import Foundation

class CustomCategoryAppRestartTests: XCTestCase {
    
    let firstCustomCategory: String = "First"
    let secondCustomCategory: String = "Second"
    let phrase: String = "Test"

    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
        }
        continueAfterFailure = false
        app.launch()
        
        // Create a custom category
        SettingsScreen.navigateToSettingsCategoryScreen()
        CustomCategoriesScreen.createCustomCategory(categoryName: firstCustomCategory)
    }
    
    func testCategoryAndPhraseCustomizationPersists() {
        // Verify that custom category exists
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Add a custom phrase to the custom category and verify that it exists
        SettingsScreen.openCategorySettings(category: firstCustomCategory)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.addPhrase(phrase)
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
     
        // Restart the app
        Utilities.restartApp()
        
        // Navigate to Settings Category Screen
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that the custom category and phrase persist after restarting
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        SettingsScreen.openCategorySettings(category: firstCustomCategory)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
    }
    
    func testHideCategoryPersists() {
        // Verify that custom category exists
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Verify that when the custom category is shown (last in the list), up button is enabled and down button is disabled
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .upEnabledOnly)
        
        // Hide the custom category
        SettingsScreen.openCategorySettings(category: firstCustomCategory)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Verify that when the category is hidden, up and down buttons are disabled
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .none)
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that after restart, hidden category's up and down buttons are disabled
        SettingsScreen.navigateToSettingsCategoryScreen()
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .none)
    }
    
    func testReorderPersists() {
        // Verify that first custom category exists
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Create second custom category and verify that it exists
        CustomCategoriesScreen.createCustomCategory(categoryName: secondCustomCategory)
        SettingsScreen.navBarBackButton.waitForExistence(timeout: 1)
        XCTAssertTrue(SettingsScreen.doesCategoryExist(secondCustomCategory))
        
        // Verify that first custom category's up and down buttons are enabled
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .both)
        
        // Verify that second custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderButtonsEquals(secondCustomCategory, reorderArrows: .upEnabledOnly)
        
        // Reorder custom categories, move first custom category to the end of the list
        let firstCategory = SettingsScreen.locateCategoryCell(firstCustomCategory)
        firstCategory.buttons[.settings.editCategories.moveDownButton].tap()
        SettingsScreen.navBarBackButton.waitForExistence(timeout: 1)
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .upEnabledOnly)
        
        // Verify that second custom category's up and down buttons are enabled
        VTAssertReorderButtonsEquals(secondCustomCategory, reorderArrows: .both)
        
        // Restart the app and navigate to Settings Category Screen
        Utilities.restartApp()
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        VTAssertReorderButtonsEquals(firstCustomCategory, reorderArrows: .upEnabledOnly)
        
        // Verify that second custom category's up and down buttons are enabled
        VTAssertReorderButtonsEquals(secondCustomCategory, reorderArrows: .both)
    }
}
