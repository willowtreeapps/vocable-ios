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
    
    private static let app = XCUIApplication()
    
    static let categoriesPageAddPhraseButton = app.buttons["settingsCategory.addPhraseButton"]
    static let editCategoryPhrasesButton = app.buttons["edit_phrases_cell"]
    static let categoriesPageEditPhraseButton = app.buttons["categoryPhrase.editButton"]
    static let categoriesPageDeletePhraseButton = app.buttons["deleteButton"]

    static func createCustomCategory(categoryName: String) {
        SettingsScreen.settingsPageAddCategoryButton.tap()
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
        _ = KeyboardScreen.checkmarkAddButton.waitForExistence(timeout: 0.5)
        KeyboardScreen.typeText(phrase)
        KeyboardScreen.checkmarkAddButton.tap()
    }
    
    static func addRandomPhrases(numberOfPhrases: Int) {
        for _ in 1...numberOfPhrases {
            let randomPhrase = KeyboardScreen.randomString(length: 2)
            categoriesPageAddPhraseButton.tap()
            KeyboardScreen.typeText(randomPhrase)
            KeyboardScreen.checkmarkAddButton.tap()
        }
    }
    
    static func returnToMainScreenFromCategoriesList() {
        // Exit the Edit Categories and Settings Screens
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        navBarDismissButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        
        // Wait for the Main Screen to appear
        XCTAssert(MainScreen.settingsButton.waitForExistence(timeout: 0.25), "Did not return to Main Screen as expected.")
    }
    
    static func returnToMainScreenFromCategoryDetails() {
        navBarBackButton.tap(afterWaitingForExistenceWithTimeout: 0.25)
        returnToMainScreenFromCategoriesList()
    }
    
    static func returnToMainScreenFromEditPhrases() {
        navBarBackButton.tap()
        returnToMainScreenFromCategoryDetails()
    }
}
