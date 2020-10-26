//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesTest: BaseTest {
    let customCategory = "Createnewcategory"

    func testAddNewPhrase() {
        let customPhrase = "ddingcustomcategoryphrasetest"
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."
        let createdCustomCategory = ("9. "+customCategory)
        
        // Add a new Category and navigate into it
        settingsScreen.navigateToSettingsCategoryScreen()
        customCategoriesScreen.createCustomCategory(categoryName: customCategory)
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()

        // Verify Phrase is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)

        settingsScreen.alertDiscardButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)
        settingsScreen.settingsPageNextButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Phrase can be added if continuing edit.
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertEqual(XCUIApplication().staticTexts.element(boundBy: 1).label, confirmationAlert)
        settingsScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(mainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() {
    // This test builds off of the last test.
        let customPhrase = "Addingcustomcategoryphrasetest"
        let createdCustomCategory = ("9. "+customCategory)

        // Navigate to Custom Category
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        
        // Edit the phrase
        customCategoriesScreen.categoriesPageEditPhraseButton.tap()
        keyboardScreen.typeText("test")
        keyboardScreen.checkmarkAddButton.tap()
        XCTAssert(mainScreen.isTextDisplayed(customPhrase+"test"), "Expected the phrase \(customPhrase+"test") to be displayed")
    }
    
    func testDeleteCustomPhrase(){
       // This test builds off of the last test.
           let customPhrase = "Test"
           let createdCustomCategory = ("9. "+customCategory)

           // Navigate to custom category
           settingsScreen.navigateToSettingsCategoryScreen()
           settingsScreen.openCategorySettings(category: createdCustomCategory)
        
           customCategoriesScreen.categoriesPageDeletePhraseButton.tap()
           settingsScreen.alertDeleteButton.tap()
           XCTAssertFalse(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to not be displayed")
    }
    
    func testDuplicatePhrasesInDifferentCategories(){
        // This test builds off of the last test.

        let createdCustomCategory = ("9. "+customCategory)
        let customCategoryTwo = "Testb"
        let customPhrase = "Testa"

        // Test Setup
        settingsScreen.navigateToSettingsCategoryScreen()
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        settingsScreen.leaveCategoryDetailButton.tap()

        // Navigate to Settings and create a custom category
        customCategoriesScreen.createCustomCategory(categoryName: customCategoryTwo)
        
        // Add an existing custom phrase
        settingsScreen.openCategorySettings(category: "10. "+customCategoryTwo)
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Edit first phrase.
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        customCategoriesScreen.categoriesPageEditPhraseButton.tap()
        keyboardScreen.typeText("Two")
        keyboardScreen.checkmarkAddButton.tap()
        
        XCTAssert(mainScreen.isTextDisplayed(customPhrase+"two"), "Expected the phrase \(customPhrase+"two") to be displayed")
        
        // Go back to the other category
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.openCategorySettings(category: "10. "+customCategoryTwo)
        XCTAssert(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to be displayed")
        
        // Cleanup: Hide categories for now until delete feature is implemented so Automation tests pass:
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.toggleHideShowCategory(category: "9. "+customCategory, toggle: "Hide")
        settingsScreen.toggleHideShowCategory(category: "9. "+customCategoryTwo, toggle: "Hide")
        
    }
    
    func testPagination(){
        let customCategoryThree = "Testc"
        let createdCustomCategory = ("9. "+customCategoryThree)
        
        settingsScreen.navigateToSettingsCategoryScreen()
        
        customCategoriesScreen.createCustomCategory(categoryName: customCategoryThree)
        settingsScreen.openCategorySettings(category: createdCustomCategory)
        
        // Verify initial state.
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        
        // Add Phrases - 4 is the max for an iphone 11 in Settings Portrait View.
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 4)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        
        customCategoriesScreen.addCustomPhrases(numberOfPhrases: 1)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 2")
        XCTAssertTrue(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 2 of 2")
        
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 2")
        mainScreen.paginationLeftButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 2 of 2")
        
        // Delete a phrase and verify pagination.
        customCategoriesScreen.categoriesPageDeletePhraseButton.firstMatch.tap()
        settingsScreen.alertDeleteButton.tap()
        
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        
        // Hide category until Delete is implemented
        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.toggleHideShowCategory(category: createdCustomCategory, toggle: "Hide")
        
    
    }
}
