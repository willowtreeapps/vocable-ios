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

    let settingsScreen = SettingsScreen()
    let keyboardScreen = KeyboardScreen()
    let mainScreen = MainScreen()
    
    let categoriesPageAddPhraseButton = XCUIApplication().buttons["settingsCategory.addPhraseButton"]
    let editCategoryPhrasesButton = XCUIApplication().buttons["edit_phrases_cell"]
    let categoriesPageEditPhraseButton = XCUIApplication().buttons["categoryPhrase.editButton"]
    let categoriesPageDeletePhraseButton = XCUIApplication().buttons["deleteButton"]

    func createCustomCategory(categoryName: String) {
        settingsScreen.settingsPageAddCategoryButton.tap()
        keyboardScreen.typeText(categoryName)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    func createAndLocateCustomCategory(_ categoryName: String) -> CategoryIdentifier {
        createCustomCategory(categoryName: categoryName)
        let customCategoryIdentifier = settingsScreen.locateCategoryCell(categoryName).element.identifier
        return CategoryIdentifier(customCategoryIdentifier)
    }
    
    func addPhrase(_ phrase: String) {
        categoriesPageAddPhraseButton.tap()
        _ = keyboardScreen.checkmarkAddButton.waitForExistence(timeout: 0.5)
        keyboardScreen.typeText(phrase)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    func addRandomPhrases(numberOfPhrases: Int) {
        for _ in 1...numberOfPhrases {
            let randomPhrase = keyboardScreen.randomString(length: 2)
            categoriesPageAddPhraseButton.tap()
            keyboardScreen.typeText(randomPhrase)
            keyboardScreen.checkmarkAddButton.tap()
        }
    }
    
    func returnToMainScreenFromCategoryDetails() {
        _ = navBarBackButton.waitForThenTap(timeout: 0.25)
        settingsScreen.returnToMainScreenFromSettingsScreen()
    }
    
    func returnToMainScreenFromEditPhrases() {
        navBarBackButton.tap()
        returnToMainScreenFromCategoryDetails()
    }
}
