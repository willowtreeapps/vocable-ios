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
    
    func addCustomPhrases(numberOfPhrases: Int) {
        for _ in 1...numberOfPhrases {
            let randomPhrase = keyboardScreen.randomString(length: 2)
            categoriesPageAddPhraseButton.tap()
            keyboardScreen.typeText(randomPhrase)
            keyboardScreen.checkmarkAddButton.tap()

            // Do this until accessibility identifiers are add and trash icon can be accessed.
            // Not needed until when change the screen to stay.
            //keyboardScreen.dismissKeyboardButton.tap()
        }
    }
    
}
