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
        // Skip the 123 (keypad), My Sayings, Recents, and Listen categories because their entries do
        // not get added to 'Recents'
        var listOfSelectedPhrases: [String] = []
        var firstPhrase = ""
        
        for categoryName in PresetCategories().list {
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
    
    func testDefaultSayingsInGeneralCategoryExist() {
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseGeneral)
    }
    
    func testSelectingCategoryChangesPhrases() {
        mainScreen.scrollRightAndTapCurrentCategory(numTimesToScroll: 1, startingCategory: "General")
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseBasicNeeds)
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        for category in PresetCategories().list {
            if listOfCategoriesToSkip.contains(category.identifier) {
                continue;
            }
            mainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
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
        settingsScreen.showCategorySwitch.tap()
        settingsScreen.leaveCategoryDetailButton.tap()
        
        // Return to the main screen
        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettingsButton.tap()
        
        // Confirm that the category is no longer accessible.
        for category in PresetCategories().list {
            // If we come across the category we expect to be hidden, fail the test. Otherwise the test will pass.
            mainScreen.locateAndSelectDestinationCategory(category.categoryIdentifier)
            if (mainScreen.selectedCategoryCell.identifier == hiddenCategoryIdentifier) {
                XCTFail("The category with identifier, '\(hiddenCategoryIdentifier)', was not hidden as expected.")
            }
        }
    }
    
    func testCustonCategoryPagination() {
        let customCategory = "Paginationtest"
        let addedCustomCategory = "9. "+customCategory
        // Adding custom category via Settings screen at it is unknown yet whether we want to implment via keyboard screen.
        settingsScreen.navigateToSettingsCategoryScreen()
        
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettingsButton.tap()
        
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 1, newCategory: customCategory)
        
        // Verify initial state.
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        
        // Add custom phrases to new category, NOTE: 8 is for an iPhone 11 (2 columns of 4).
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: addedCustomCategory)
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 8)
        
        // Navigate to home screen to verify page numbers
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 1, newCategory: customCategory)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        
        // Add custom phrases to new category
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: addedCustomCategory)
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 1)
        
        // Navigate to home screen to verify page numbers.
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 2")
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
        
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 2 of 2")
        
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 2")
        mainScreen.paginationLeftButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 2 of 2")
        
        // Delete a phrase and verify pagination.
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: addedCustomCategory)
        customCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
        settingsScreen.alertDeleteButton.tap()
        
        // Navigate to home screen and verify page numbers
        settingsScreen.navigateToMainScreenFromSettings(from: "categoryDetails")
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        
        // Hide new category to Reset state until delete functionality is implemented:
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.navigateToCategory(category: addedCustomCategory)
        settingsScreen.toggleHideShowCategory(category: addedCustomCategory, toggle: "Hide")
    }
    
    private func verifyGivenPhrasesDisplay(setOfPhrases: [String]) {
        for phrase in setOfPhrases {
            XCTAssert(mainScreen.isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
    
}
