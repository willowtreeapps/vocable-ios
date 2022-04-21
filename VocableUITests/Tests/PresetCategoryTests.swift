//
//  CustomCategoryTests.swift
//  VocableUITests
//
//  Created by Canan Arikan and Rudy Salas on 3/29/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class PresetCategoryTests: BaseTest {
    let nameSuffix = "test"
    
    func testRenameCategory() {
        let categoryName = "General"
        let renamedCategory = categoryName + nameSuffix
        let categoryIdentifier = CategoryTitleCellIdentifier(CategoryIdentifier.general).identifier
        
        //Rename the preset category
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: categoryName)
        settingsScreen.renameCategoryButton.tap()
        keyboardScreen.typeText(nameSuffix)
        keyboardScreen.checkmarkAddButton.tap()
        XCTAssertEqual(settingsScreen.categoryDetailsTitle.label, renamedCategory)
        
        settingsScreen.leaveCategoriesButton.tap()
        XCTAssertTrue(settingsScreen.doesCategoryExist(renamedCategory))
        
        // Return to the main screen
        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettingsButton.tap()
        
        // Confirm that the category is renamed from main screen
        mainScreen.locateAndSelectDestinationCategory(.general)
        XCTAssertEqual(mainScreen.selectedCategoryCell.identifier, categoryIdentifier)
        //XCUIApplication().cells.staticTexts["Generaltest"].label
    }
    
    func testRemoveCategory() {
        let categoryName = "Environment"
        let categoryIdentifier = CategoryTitleCellIdentifier(CategoryIdentifier.environment).identifier

        //Remove the preset category
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: categoryName)
        settingsScreen.removeCategoryButton.tap()
        settingsScreen.alertRemoveButton.tap()
        XCTAssertFalse(settingsScreen.doesCategoryExist(categoryName))
        
        // Return to the main screen
        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettingsButton.tap()
        
        // Confirm that the category is no longer accessible from main screen
        for category in PresetCategories().list {
            // If we come across the category we expect to be removed, fail the test. Otherwise the test will pass
            mainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
            if (mainScreen.selectedCategoryCell.identifier == categoryIdentifier) {
                XCTFail("The category with identifier, '\(categoryIdentifier)', was not removed as expected.")
            }
        }
    }
    
    func testShowHideButtonIsDisabledForMySayingsCategory() {
        let categoryName = "My Sayings"
       
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: categoryName)
        XCTAssertFalse(settingsScreen.showCategoryButton.isEnabled)
    }
    
    func testAddDuplicatePhrasesToMySayings() {
        let testPhrase = "Test"
        
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.favoriteButton.tap()
        keyboardScreen.dismissKeyboardButton.tap()
       
        mainScreen.locateAndSelectDestinationCategory(.mySayings)
        XCTAssertTrue(mainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the first phrase \(testPhrase) to be added to and displayed in 'My Sayings'")

        // Add the same phrase again to the My Sayings
        mainScreen.addPhraseLabel.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        keyboardScreen.createDuplicateButton.tap()
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = XCUIApplication().staticTexts.containing(phrasePredicate)
        phraseQuery.element.waitForExistence(timeout: 2)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be presentin 'My Sayings'")
    }
    
}
