//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: BaseTest {

    func testDefaultCategoriesExist() {
        for categoryName in mainScreen.defaultCategories {
            XCTAssert(mainScreen.isTextDisplayed(categoryName), "Expected the current category name to be \(categoryName)")
            mainScreen.categoryRightButton.tap()
        }
    }
    
    func testDefaultSayingsInGeneralCategoryExist() {
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseGeneral)
    }
    
    func testSelectingCategoryChangesPhrases() {
        mainScreen.scrollRightAndTapCurrentCategory(numTimesToScroll: 1)
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseBasicNeeds)
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        XCUIApplication().collectionViews.staticTexts[mainScreen.defaultPhraseGeneral[0]].tap()
        XCTAssertEqual(mainScreen.outputLabel.label, mainScreen.defaultPhraseGeneral[0])
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 2, newCategory: nil)
        XCUIApplication().collectionViews.staticTexts[mainScreen.defaultPhrase123[0]].tap()
        XCTAssertEqual(mainScreen.outputLabel.label, mainScreen.defaultPhrase123[0])
    }
    
    func testDisablingCategory() {
        let generalCategoryText = "1. General"
        let hiddenGeneralCategoryText = "General"
        
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.toggleHideShowCategory(category: generalCategoryText, toggle: "Hide")

        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettingsButton.tap()
        
        XCTAssertFalse(XCUIApplication().collectionViews.staticTexts[mainScreen.defaultCategories[0]].exists)
        
        //since settings changes persist through app restarts, we have to reset the categories back to default after our test.
        //once the reset settings functionality is implemented, or better yet, a reset settings environment variable, this can be deleted
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.toggleHideShowCategory(category: hiddenGeneralCategoryText, toggle: "Show")
    }
    
    func testCustonCategoryPagination() {
        let customCategory = "Paginationtest"
        let addedCustomCategory = "8. "+customCategory
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
