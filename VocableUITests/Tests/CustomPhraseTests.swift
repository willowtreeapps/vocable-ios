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
        CustomCategoriesScreen.phraseCell(phraseId).buttons["editButton"].tap()
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
        // Navigate to our test category
        MainScreen.navigateToSettingsAndOpenCategory(name: editableCategory.presetCategory.utterance)
        CustomCategoriesScreen.editCategoryPhrasesButton.tap()

        // Duplicate the phrase in this category
        let originalPhraseId = editableCategory.presetPhrases[0].id
        let duplicatePhrase = editableCategory.presetPhrases[0].utterance
        CustomCategoriesScreen.addPhrase(duplicatePhrase)
        KeyboardScreen.createDuplicateButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        
        // Wait for the keyboard to dismiss
        _ = CustomCategoriesScreen.navBarBackButton.waitForExistence(timeout: 0.5)
        
        // We have 2 phrase cells now
        let allPhraseCells = XCUIApplication().cells.allElementsBoundByIndex
        XCTAssertEqual(allPhraseCells.count, 2)
        XCTAssertNotEqual(allPhraseCells[0].identifier, originalPhraseId)
        XCTAssertEqual(allPhraseCells[1].identifier, originalPhraseId)
        // TODO: Re-visit this idea, creating a new VT assertion that tests these conditions. VTAssertDuplicatePhrases?
        // there are now 2 cells
        // one of the cells is the original...proven by the identifier
        // one of the cells is the duplicate:
            // it matches the label (both have the same utterance)
            // it has its own ID
    }
    
}
