//
//  CustomCategoriesScreen.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Updated by Canan Arikan and Rudy Salas on 04/07/2022
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesScreen: BaseScreen {
    
    static let categoriesPageAddPhraseButton = XCUIApplication().buttons[.settings.editPhrases.addPhraseButton]
    static let editCategoryPhrasesButton = XCUIApplication().buttons[.settings.editCategoryDetails.editPhrasesButton]
    static let categoriesPageDeletePhraseButton = XCUIApplication().buttons[.settings.editPhrases.deletePhraseButton]

    static var firstPhraseCell: XCUIElement {
        let firstPhraseId = XCUIApplication().cells.firstMatch.identifier
        return XCUIApplication().cells[firstPhraseId]
    }
    
    static func phraseCell(_ phraseId: String) -> XCUIElementQuery {
        return XCUIApplication().cells.matching(identifier: phraseId)
    }
    
    static func createCustomCategory(categoryName: String) {
        SettingsScreen.addCategoryButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        KeyboardScreen.typeText(categoryName)
        KeyboardScreen.checkmarkAddButton.tap()
    }
    
    static func createAndLocateCustomCategory(_ categoryName: String) -> CategoryIdentifier {
        createCustomCategory(categoryName: categoryName)
        let customCategoryIdentifier = SettingsScreen.locateCategoryCell(categoryName).element.identifier
        return CategoryIdentifier(customCategoryIdentifier)
    }
    
    static func addPhrase(_ phrase: String) {
        categoriesPageAddPhraseButton.tap()
        _ = KeyboardScreen.checkmarkAddButton.waitForExistence(timeout: 0.75)
        KeyboardScreen.typeText(phrase)
        KeyboardScreen.checkmarkAddButton.tap()
        _ = categoriesPageAddPhraseButton.waitForExistence(timeout: 0.5)
    }
    
    static func addRandomPhrases(numberOfPhrases: Int) {
        for _ in 1...numberOfPhrases {
            let randomPhrase = KeyboardScreen.randomString(length: 2)
            categoriesPageAddPhraseButton.tap()
            KeyboardScreen.typeText(randomPhrase)
            KeyboardScreen.checkmarkAddButton.tap()
        }
        _ = categoriesPageAddPhraseButton.waitForExistence(timeout: 0.5)
    }
    
    static func returnToMainScreenFromCategoriesList() {
        // Exit the Edit Categories and Settings Screens
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        navBarDismissButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        
        // Wait for the Main Screen to appear
        XCTAssert(MainScreen.settingsButton.waitForExistence(timeout: 0.5), "Did not return to Main Screen as expected.")
    }
    
    static func returnToMainScreenFromCategoryDetails() {
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        returnToMainScreenFromCategoriesList()
    }
    
    static func returnToMainScreenFromEditPhrases() {
        navBarBackButton.tap()
        returnToMainScreenFromCategoryDetails()
    }
    
    static func navigateToSettingsCategoryScreenFromCategoryEditPhrases() {
        // Exit the Edit Phrases and Category Detail Screens
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.5)
        
        // Wait for the Categories Screen to appear
        XCTAssert(SettingsScreen.addCategoryButton.waitForExistence(timeout: 0.5), "Did not return to Settings Categories Screen as expected.")
    }
    
}
