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
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText("A")
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)

        SettingsScreen.alertDiscardButton.tap()
        XCTAssertTrue(CustomCategoriesScreen.emptyStateAddPhraseButton.exists)

        // Verify Phrase can be added if continuing edit.
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText("A")
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)
        SettingsScreen.alertContinueButton.tap()

        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()

        XCTAssert(MainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() {
        let customPhrase = "Add"
        
        // Add our test phrase
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Edit the phrase
        XCUIApplication().buttons[customPhrase].tap()
        KeyboardScreen.typeText("test")
        KeyboardScreen.checkmarkAddButton.tap()
        XCTAssert(MainScreen.isTextDisplayed(customPhrase+"test"), "Expected the phrase \(customPhrase+"test") to be displayed")
    }
    
    func testDeleteCustomPhrase() {
        let customPhrase = "Test"
        
        // Add our test phrase
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Confirm that our phrase to-be-deleted has been created
        XCTAssert(MainScreen.isTextDisplayed(customPhrase), "Expected the phrase \(customPhrase) to be displayed")
        
        CustomCategoriesScreen.categoriesPageDeletePhraseButton.tap()
        SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        XCTAssertTrue(CustomCategoriesScreen.emptyStateAddPhraseButton.exists, "Expected the phrase \(customPhrase) to not be displayed")
    }
    
    func testCanAddDuplicatePhrasesToCategories() {
        let testPhrase = "Testa"

        // Add our first test phrase
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Assert that our phrase was added
        XCTAssertTrue(MainScreen.isTextDisplayed(testPhrase), "Expected our first phrase to be added to category.")

        // Add the same phrase again to the same category
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.checkmarkAddButton.tap()
        KeyboardScreen.createDuplicateButton.tap()
        
        // Assert that now we have two cells containing the same phrase
        let phrasePredicate = NSPredicate(format: "label MATCHES %@", testPhrase)
        let phraseQuery = XCUIApplication().staticTexts.containing(phrasePredicate)
        _ = phraseQuery.element.waitForExistence(timeout: 2)
        XCTAssertEqual(phraseQuery.count, 2, "Expected both phrases to be present")
    }
    
}
