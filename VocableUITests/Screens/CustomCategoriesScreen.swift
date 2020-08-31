//
//  CustomCategoriesScreen.swift
//  VocableUITests
//
//  Created by Sashank Patel on 8/25/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class CustomCategoriesScreen {

    let settingsScreen = SettingsScreen()
    let keyboardScreen = KeyboardScreen()
    let mainScreen = MainScreen()
    
    let categoriesPageAddPhraseButton = XCUIApplication().buttons["settingsCategory.addPhraseButton"]
    let categoriesPageEditPhraseButton = XCUIApplication().buttons["categoryPhrase.editButton"]
    let categoriesPageDeletePhraseButton = XCUIApplication().buttons["categoryPhrase.deleteButton"]

    
    func createCustomCategory(categoryName: String){
        settingsScreen.settingsPageAddCategoryButton.tap()
        keyboardScreen.typeText(categoryName)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    func addCustomPhrases(numberOfSayings: Int){        
         for _ in 1...numberOfSayings {
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
