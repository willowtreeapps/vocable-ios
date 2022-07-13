//
//  PresetCategoryAppRestartTests.swift
//  VocableUITests
//
//  Created by Canan Arikan on 7/8/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest
import Foundation


class PresetCategoryAppRestartTests: XCTestCase {
    
    let category = "General"
    let secondCategory = "Basic Needs"
    let phrase = "Test"
    let app = XCUIApplication()
    
    override func setUp() {
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
        }
        continueAfterFailure = false
        app.launch()
    }
    
    func testAddedPhrasePersists() {
        // Navigate to our test category and add a phrase
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.addPhrase(phrase)
        
        // Verify that phrase does exist in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
        
        // Verify that phrase does exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.general)
        XCTAssertTrue(MainScreen.phraseDoesExist(phrase))
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that the added phrase persists after restarting
        MainScreen.locateAndSelectDestinationCategory(.general)
        XCTAssertTrue(MainScreen.phraseDoesExist(phrase))
    }
    
    func testMySayingsAddedPhrasePersists() {
        let category = "My Sayings"
        // Navigate to our test category and add a phrase
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: category)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        CustomCategoriesScreen.addPhrase(phrase)
        
        // Verify that phrase does exist in Category Details Screen
        XCTAssertTrue(CustomCategoriesScreen.phraseDoesExist(phrase))
        
        // Verify that phrase does exist in Main Screen
        CustomCategoriesScreen.returnToMainScreenFromEditPhrases()
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        XCTAssertTrue(MainScreen.phraseDoesExist(phrase))
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that the added phrase persists after restarting
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        XCTAssertTrue(MainScreen.phraseDoesExist(phrase))
    }
    
    func testRecentsAddedPhrasePersists() {
        // Navigate to General and tap first phrase
        MainScreen.locateAndSelectDestinationCategory(.general)
        let firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstPhrase].tap()
        
        // Verif that Recents shows the tapped phrase (first phrase of General)
        MainScreen.locateAndSelectDestinationCategory(.recents)
        XCTAssertTrue(MainScreen.phraseDoesExist(firstPhrase))
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that the tapped phrase persists after restarting
        MainScreen.locateAndSelectDestinationCategory(.recents)
        XCTAssertTrue(MainScreen.phraseDoesExist(firstPhrase))
    }
    
    func testHideCategoryPersists() {
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that when the first preset category is shown, up button is disabled and down button is enabled
        VTAssertReorderArrowsEqual(.downEnabledOnly, for: category)
        
        // Hide the preset category
        SettingsScreen.openCategorySettings(category: category)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Verify that when the category is hidden, up and down buttons are disabled
        VTAssertReorderArrowsEqual(.none, for: category)
        
        // Restart the app
        Utilities.restartApp()
        
        // Verify that after restart, hidden category's up and down buttons are disabled
        SettingsScreen.navigateToSettingsCategoryScreen()
        VTAssertReorderArrowsEqual(.none, for: category)
    }
    
    func testReorderPersists() {
        // Navigate to our test category
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that first preset category's up button is disabled and down button is enabled
        VTAssertReorderArrowsEqual(.downEnabledOnly, for: category)
        
        // Verify that second preset category's (second in the list) up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: secondCategory)
        
        // Reorder categories, move first preset category to the second of the list
        let firstCategory = SettingsScreen.locateCategoryCell(category)
        firstCategory.buttons[.settings.editCategories.moveDownButton].tap()
        SettingsScreen.navBarBackButton.waitForExistence(timeout: 1)
        
        // Verify that first preset category's (now second in the list) up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: category)
        
        // Verify that second custom category's (now first in the list) up button is disabled and down button is enabled
        VTAssertReorderArrowsEqual(.downEnabledOnly, for: secondCategory)
        
        // Restart the app and navigate to Settings Category Screen
        Utilities.restartApp()
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Verify that first preset category's (now second in the list) up and down buttons are enabled
        VTAssertReorderArrowsEqual(.both, for: category)
        
        // Verify that second preset category's (now first in the list) up button is disabled and down button is enabled
        VTAssertReorderArrowsEqual(.downEnabledOnly, for: secondCategory)
    }
    
    func testRenameCategory() {
        let categoryName = "Basic Needs"
        let nameSuffix = "add"
        let renamedCategory = categoryName + nameSuffix
        let categoryIdentifier = (CategoryIdentifier.basicNeeds).identifier
        
        //Rename the preset category
        SettingsScreen.navigateToSettingsCategoryScreen()
        SettingsScreen.openCategorySettings(category: categoryName)
        SettingsScreen.renameCategoryButton.tap()
        KeyboardScreen.typeText(nameSuffix)
        KeyboardScreen.checkmarkAddButton.tap()
        XCTAssertEqual(SettingsScreen.title.label, renamedCategory)
        
        // Confirm that the category is renamed from categories list
        SettingsScreen.navBarBackButton.tap()
        XCTAssertTrue(SettingsScreen.doesCategoryExist(renamedCategory))
        
        // Confirm that the category is renamed from main screen
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        let isSelectedPredicate = NSPredicate(format: "isSelected == true")
        let query = XCUIApplication().cells.containing(isSelectedPredicate)
        XCTAssertEqual(query.staticTexts.element.label, renamedCategory)
        XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryIdentifier)
        
        // Restart the app and navigate to Settings Category Screen
        Utilities.restartApp()
        SettingsScreen.navigateToSettingsCategoryScreen()
        
        // Confirm that the renamed category name persists
        CustomCategoriesScreen.returnToMainScreenFromCategoriesList()
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        XCTAssertEqual(query.staticTexts.element.label, renamedCategory)
    }
}
