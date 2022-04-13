//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Updated by Rudy Salas, Canan Arikan, and Rhonda Oglesby on 03/30/2022
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: BaseTest {
    
    private let listOfCategoriesToSkip = [CategoryTitleCellIdentifier(CategoryIdentifier.keyPad).identifier,
                                          CategoryTitleCellIdentifier(CategoryIdentifier.mySayings).identifier,
                                          CategoryTitleCellIdentifier(CategoryIdentifier.listen).identifier,
                                          CategoryTitleCellIdentifier(CategoryIdentifier.recents).identifier]
    
     // For each preset category (the first 5 categories), tap() the top left
     // phrase, then verify that all selected phrases appear in "Recents"
    func testRecentScreen_ShowsPressedButtons(){
        var listOfSelectedPhrases: [String] = []
        var firstPhrase = ""
        
        for categoryName in PresetCategories().list {
            
            // Skip the 123 (keypad), My Sayings, Recents, and Listen categories because their entries do
            // not get added to 'Recents'
            if listOfCategoriesToSkip.contains(categoryName.identifier) {
                continue;
            }
            mainScreen.locateAndSelectDestinationCategory(categoryName.categoryIdentifier)
            firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhrase].tap()
            listOfSelectedPhrases.append(firstPhrase)
        }
        mainScreen.locateAndSelectDestinationCategory(.recents)
        
        for phrase in listOfSelectedPhrases {
            XCTAssertTrue(mainScreen.locatePhraseCell(phrase: phrase).exists, "Expected \(phrase) to appear in Recents category")
        }
    }
    
    func testDefaultCategoriesExist() {
        for categoryName in PresetCategories().list {
            mainScreen.locateAndSelectDestinationCategory(categoryName.categoryIdentifier)
            XCTAssertEqual(mainScreen.selectedCategoryCell.identifier, categoryName.identifier, "Preset category with ID '\(categoryName.identifier)' was not found")
        }
    }
    
    func testSelectingCategoryChangesPhrases() {
        // Navigate to a category and grab it's first, top most, phrase
        mainScreen.locateAndSelectDestinationCategory(.environment)
        let firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        
        // Navigate to a different category and verify the top most phrase listed has changed
        mainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        let secondPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertNotEqual(firstPhrase, secondPhrase, "The list of phrases did not change between selected categories.")
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        for category in PresetCategories().list {
            if listOfCategoriesToSkip.contains(category.identifier) {
                continue;
            }
            mainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
            _ = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).waitForExistence(timeout: 0.5) // Wait for scrolling to stop
            let firstPhraseInCategory = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhraseInCategory].tap()
            XCTAssertEqual(mainScreen.outputLabel.label, firstPhraseInCategory)
        }
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        mainScreen.locateAndSelectDestinationCategory(.keyPad)
        let firstKeypadNumber = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstKeypadNumber].tap()
        XCTAssertEqual(mainScreen.outputLabel.label, firstKeypadNumber)
    }
    
    func testDisablingCategory() {
        let hiddenCategoryName = "General"
        let hiddenCategoryIdentifier = CategoryTitleCellIdentifier(CategoryIdentifier.general).identifier
        
        settingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(settingsScreen.locateCategoryCell(hiddenCategoryName).element.exists)

        // Navigate to the category and hide it.
        settingsScreen.openCategorySettings(category: hiddenCategoryName)
        settingsScreen.showCategoryButton.tap()
        settingsScreen.navBarBackButton.tap()
        
        // Return to the main screen
        settingsScreen.navBarBackButton.tap()
        settingsScreen.navBarDismissButton.tap()
        
        // Confirm that the category is no longer accessible.
        for category in PresetCategories().list {
            // If we come across the category we expect to be hidden, fail the test. Otherwise the test will pass.
            mainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
            if (mainScreen.selectedCategoryCell.identifier == hiddenCategoryIdentifier) {
                XCTFail("The category with identifier, '\(hiddenCategoryIdentifier)', was not hidden as expected.")
            }
        }
    }
    
}
