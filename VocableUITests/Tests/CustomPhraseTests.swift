//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomPhraseTests: CustomPhraseBaseTest {

    func testAddNewPhrase() {
        let customPhrase = "dd"

        // Verify Phrase is not added if edits are discarded
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(keyboardScreen.alertMessageLabel.exists)

        settingsScreen.alertDiscardButton.tap()
        XCTAssertTrue(customCategoriesScreen.emptyStateAddPhraseButton.exists)

        // Verify Phrase can be added if continuing edit.
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText("A")
        keyboardScreen.dismissKeyboardButton.tap()
        XCTAssertTrue(keyboardScreen.alertMessageLabel.exists)
        settingsScreen.alertContinueButton.tap()

        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()

        XCTAssert(mainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() {
        let customPhrase = "Add"
        
        // Add our test phrase
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
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(customPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Confirm that our phrase to-be-deleted has been created
        XCTAssert(mainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to be displayed")
        
        customCategoriesScreen.categoriesPageDeletePhraseButton.tap()
        settingsScreen.alertDeleteButton.tap()
        XCTAssertTrue(customCategoriesScreen.emptyStateAddPhraseButton.exists, "Expected the phrase \(customPhrase) to not be displayed")
    }
    
    func testCanAddDuplicatePhrasesToCategories() {
        let testPhrase = "Testa"

        // Add our first test phrase
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        
        // Assert that our phrase was added
        XCTAssertTrue(mainScreen.isTextDisplayed(testPhrase), "Expected our first phrase to be added to category.")

        // Add the same phrase again to the same category
        customCategoriesScreen.categoriesPageAddPhraseButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.checkmarkAddButton.tap()
        keyboardScreen.createDuplicateButton.tap()
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = XCUIApplication().staticTexts.containing(phrasePredicate)
        phraseQuery.element.waitForExistence(timeout: 2)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be present")
    }
    
}
