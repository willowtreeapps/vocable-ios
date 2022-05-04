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
    
    private let listOfCategoriesToSkip = [CategoryIdentifier.keyPad.identifier,
                                          CategoryIdentifier.mySayings.identifier,
                                          CategoryIdentifier.listen.identifier,
                                          CategoryIdentifier.recents.identifier]
    
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
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhrase].tap()
            listOfSelectedPhrases.append(firstPhrase)
        }
        MainScreen.locateAndSelectDestinationCategory(.recents)
        
        for phrase in listOfSelectedPhrases {
            XCTAssertTrue(MainScreen.locatePhraseCell(phrase: phrase).exists, "Expected \(phrase) to appear in Recents category")
        }
    }
    
    func testDefaultCategoriesExist() {
        for categoryName in PresetCategories().list {
            MainScreen.locateAndSelectDestinationCategory(categoryName)
            XCTAssertEqual(MainScreen.selectedCategoryCell.identifier, categoryName.identifier, "Preset category with ID '\(categoryName.identifier)' was not found")
        }
    }
    
    func testSelectingCategoryChangesPhrases() {
        // Navigate to a category and grab it's first, top most, phrase
        MainScreen.locateAndSelectDestinationCategory(.environment)
        let firstPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        
        // Navigate to a different category and verify the top most phrase listed has changed
        MainScreen.locateAndSelectDestinationCategory(.basicNeeds)
        let secondPhrase = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCTAssertNotEqual(firstPhrase, secondPhrase, "The list of phrases did not change between selected categories.")
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        for category in PresetCategories().list {
            if listOfCategoriesToSkip.contains(category.identifier) {
                continue;
            }
            MainScreen.locateAndSelectDestinationCategory(category)
            _ = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).waitForExistence(timeout: 0.5) // Wait for scrolling to stop
            let firstPhraseInCategory = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
            XCUIApplication().collectionViews.staticTexts[firstPhraseInCategory].tap()
            XCTAssertEqual(MainScreen.outputLabel.label, firstPhraseInCategory)
        }
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        MainScreen.locateAndSelectDestinationCategory(.keyPad)
        let firstKeypadNumber = XCUIApplication().collectionViews.staticTexts.element(boundBy: 0).label
        XCUIApplication().collectionViews.staticTexts[firstKeypadNumber].tap()
        XCTAssertEqual(MainScreen.outputLabel.label, firstKeypadNumber)
    }
    
    func testDisablingCategory() {
        let hiddenCategoryName = "General"
        let hiddenCategoryIdentifier = CategoryIdentifier.general.identifier
        
        SettingsScreen.navigateToSettingsCategoryScreen()
        XCTAssertTrue(SettingsScreen.locateCategoryCell(hiddenCategoryName).element.exists)

        // Navigate to the category and hide it.
        SettingsScreen.openCategorySettings(category: hiddenCategoryName)
        SettingsScreen.showCategoryButton.tap()
        SettingsScreen.navBarBackButton.tap()
        
        // Return to the main screen
        SettingsScreen.navBarBackButton.tap()
        SettingsScreen.navBarDismissButton.tap()
        
        // Confirm that the category is no longer accessible.
        for category in PresetCategories().list {
            // If we come across the category we expect to be hidden, fail the test. Otherwise the test will pass.
            MainScreen.locateAndSelectDestinationCategory(category)
            if MainScreen.selectedCategoryCell.identifier == hiddenCategoryIdentifier {
                XCTFail("The category with identifier, '\(hiddenCategoryIdentifier)', was not hidden as expected.")
            }
        }
    }
    
}
