//
//  CustomCategoryAppRestartTests.swift
//  VocableUITests
//
//  Created by Canan Arikan on 6/16/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoryAppRestartTests: XCTestCase {
    
    private(set) var firstCustomCategory: String = "First"
    private(set) var secondCustomCategory: String = "Second"
    private(set) var phrase: String = "Test"

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
        app.terminate()
        app.activate()
        
        // Navigate to Settings Category Screen
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that the custom category and phrase persist after restarting
        SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        SettingsScreen.openCategorySettings(category: firstCustomCategory)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
    }
    
    // 16 seconds
    func testHideCategoryPersists() {
        // Verify that custom category exists
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Verify that when the custom category is shown (last in the list), up button is enabled and down button is disabled
        let shownCategory = SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertTrue(shownCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(shownCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(shownCategory.element.isEnabled)
        
        // Hide the custom category
        SettingsScreen.openCategorySettings(category: firstCustomCategory)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Verify that when the category is hidden, up and down buttons are disabled
        let hiddenCategory = SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.element.isEnabled)
        
        // Restart the app
        app.terminate()
        app.activate()
        
        // Verify that after restart, hidden category's up and down buttons are disabled
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(hiddenCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        XCTAssertTrue(hiddenCategory.element.isEnabled)        
    }
    
    func testReorderPersists() {
        // Verify that first custom category exists
        XCTAssertTrue(SettingsScreen.doesCategoryExist(firstCustomCategory))
        
        // Create second custom category and verify that it exists
        CustomCategoriesScreen.createCustomCategory(categoryName: secondCustomCategory)
        XCTAssertTrue(SettingsScreen.doesCategoryExist(secondCustomCategory))
        
        // Verify that first custom category's up and down buttons are enabled
        let firstCategory = SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertTrue(firstCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertTrue(firstCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Verify that second custom category's (last in the list), up button is enabled and down button is disabled
        let secondCategory = SettingsScreen.locateCategoryCell(secondCustomCategory)
        XCTAssertTrue(secondCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(secondCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Reorder custom categories, move first custom category to the end of the list
        SettingsScreen.locateCategoryCell(firstCustomCategory)
        firstCategory.buttons[.settings.editCategories.moveDownButton].tap()
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        XCTAssertTrue(firstCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(firstCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Verify that second custom category's up and down buttons are enabled
        SettingsScreen.locateCategoryCell(secondCustomCategory)
        XCTAssertTrue(secondCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertTrue(secondCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Restart the app
        app.terminate()
        app.activate()

        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that first custom category's (last in the list), up button is enabled and down button is disabled
        SettingsScreen.locateCategoryCell(firstCustomCategory)
        XCTAssertTrue(firstCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertFalse(firstCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
        
        // Verify that second custom category's up and down buttons are enabled
        SettingsScreen.locateCategoryCell(secondCustomCategory)
        XCTAssertTrue(secondCategory.buttons[.settings.editCategories.moveUpButton].isEnabled)
        XCTAssertTrue(secondCategory.buttons[.settings.editCategories.moveDownButton].isEnabled)
    }
}
