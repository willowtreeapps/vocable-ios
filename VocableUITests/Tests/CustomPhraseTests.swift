//
//  CustomCategoriesTests.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Updated by Rudy Salas and Canan Arikan on 05/16/2022.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class CustomPhraseTests: XCTestCase {

    let editableCategory = Category("Test") {
        Phrase("Hello")
    }
    
    let emptyCategory = Category("Empty") {
        // Empty
    }
    
    override func setUp() {
        let app = XCUIApplication()
        app.configure {
            Arguments(.resetAppDataOnLaunch, .disableAnimations)
            Environment(.overridePresets) {
                Presets {
                    editableCategory
                    emptyCategory
                }
            }
        }
        app.launch()
    }
    
    func testAddNewPhrase() {
        let customPhrase = "dd"
        
        // Navigate to our test category
        MainScreen.navigateToSettingsAndOpenCategory(name: emptyCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()

        // Verify Phrase is not added if edits are discarded
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText("A")
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)

        SettingsScreen.alertDiscardButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        XCTAssertTrue(CustomCategoriesScreen.emptyStateAddPhraseButton.exists)

        // Verify Phrase can be added if continuing edit
        CustomCategoriesScreen.categoriesPageAddPhraseButton.tap()
        KeyboardScreen.typeText("A")
        KeyboardScreen.navBarDismissButton.tap()
        XCTAssertTrue(KeyboardScreen.alertMessageLabel.exists)
        SettingsScreen.alertContinueButton.tap(afterWaitingForExistenceWithTimeout: 0.5)

        KeyboardScreen.typeText(customPhrase)
        KeyboardScreen.checkmarkAddButton.tap()

        XCTAssert(MainScreen.isTextDisplayed("A"+customPhrase), "Expected the phrase \("A"+customPhrase) to be displayed")
    }

    func testCustomPhraseEdit() {
        let editSuffix = "test"
        let phraseId = editableCategory.presetPhrases[0].id
        let updatedPhrase = editableCategory.presetPhrases[0].utterance + editSuffix
        
        // Navigate to our test category
        MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        // Edit an existing phrase
        CustomCategoriesScreen.phraseCell(phraseId).buttons[.settings.editPhrases.editPhraseButton].tap()
        KeyboardScreen.typeText("test")
        KeyboardScreen.checkmarkAddButton.tap()
        
        // Verify phrase has been updated
        XCTAssert(MainScreen.isTextDisplayed(updatedPhrase), "Expected the phrase \(updatedPhrase) to be displayed")
    }
    
    func testDeleteCustomPhrase() {
        MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()
        
        CustomCategoriesScreen.categoriesPageDeletePhraseButton.tap()
        SettingsScreen.alertDeleteButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        XCTAssertTrue(CustomCategoriesScreen.emptyStateAddPhraseButton.exists, "Expected the phrase to be deleted")
    }
    
    func testCanAddDuplicatePhrasesToCategories() {
        // Navigate to our test category.
        MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()

        // Duplicate the phrase in this category.
        let originalPhraseId = editableCategory.presetPhrases[0].id
        let duplicatedPhrase = editableCategory.presetPhrases[0].utterance
        CustomCategoriesScreen.addPhrase(duplicatedPhrase)
        KeyboardScreen.createDuplicateButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        
        // Wait for the keyboard to dismiss.
        _ = CustomCategoriesScreen.navBarBackButton.waitForExistence(timeout: 0.5)
        
        // Verify we now have 2 phrases, with matching labels, but unique identifiers.
        let allPhraseCells = XCUIApplication().cells
        XCTAssertEqual(allPhraseCells.count, 2)
        XCTAssertEqual(allPhraseCells.matching(identifier: originalPhraseId).count, 1)
        XCTAssertEqual(allPhraseCells.staticTexts.matching(identifier: duplicatedPhrase).count, 2)
    }
    
}
