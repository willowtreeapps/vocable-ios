//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesTests: CustomCategoriesBaseTest {

    func testAddNewPhrase() {
        let customPhrase = "dd"
        let confirmationAlert = "Are you sure? Going back before saving will clear any edits made."
        let areYouSureAlert = NSPredicate(format: "label CONTAINS %@", confirmationAlert)
        
        // Navigate to our test category (created in the base class setup() method)
        customCategoriesScreen.editCategoryPhrasesCell.tap()
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()

        // Verify Phrase is not added if edits are discarded
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(XCUIApplication().staticTexts.containing(areYouSureAlert).element.exists)

        settingsScreen.alertDiscardButton.tap()
        XCTAssertFalse(XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: "A").element.exists)

        // Verify Phrase can be added if continuing edit.
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(XCUIApplication().staticTexts.containing(areYouSureAlert).element.exists)
        settingsScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(mainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() {
        let customPhrase = "Add"
        
        // Add our test phrase
        customCategoriesScreen.editCategoryPhrasesCell.tap()
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Edit the phrase
        // TODO: Refactor customCategoriesScreen.categoriesPageEditPhraseButton after Category List UI updates: issue #492 ... need identifiers?
        XCUIApplication().buttons[customPhrase].tap()
        keyboardScreen.typeText("test")
        keyboardScreen.checkmarkAddButton.tap()
        XCTAssert(mainScreen.isTextDisplayed(customPhrase+"test"), "Expected the phrase \(customPhrase+"test") to be displayed")
    }
    
    func testDeleteCustomPhrase() {
        let customPhrase = "Test"
        
        // Add our test phrase
        customCategoriesScreen.editCategoryPhrasesCell.tap()
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Confirm that our phrase to-be-deleted has been created
        XCTAssert(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to be displayed")
        
        // TODO: customCategoriesScreen.categoriesPageDeletePhraseButton after Category List UI updates: issue #492 ... need identifiers?
        XCUIApplication().buttons["trash"].tap()
        settingsScreen.alertDeleteButton.tap()
        XCTAssertFalse(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to not be displayed")
    }
    
    func testCanAddDuplicatePhrasesToCategories() {
        let testPhrase = "Testa"

        // Add our first test phrase
        customCategoriesScreen.editCategoryPhrasesCell.tap()
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Assert that our phrase was added
        XCTAssertTrue(mainScreen.isTextDisplayed(testPhrase), "Expected our first phrase to be added to category.")

        // Add the same phrase again to the same category
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = XCUIApplication().staticTexts.containing(phrasePredicate)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be present")
    }
    
    // TODO: Disabled for now. Moving it to a different test class as part of issue #405; tracked in issue #470
    // https://github.com/willowtreeapps/vocable-ios/issues/470 -> Implementation
    // https://github.com/willowtreeapps/vocable-ios/issues/405 -> Parent
    func testPagination() {
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
