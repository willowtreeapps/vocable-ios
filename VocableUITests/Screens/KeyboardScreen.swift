//
//  KeyboardScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreen {
    private let app = XCUIApplication()
    
    let keyboardTextView = XCUIApplication().textViews["keyboard.textView"]
    let dismissKeyboardButton = XCUIApplication().buttons["keyboard.dismissButton"]
    let favoriteButton = XCUIApplication().buttons["keyboard.favoriteButton"]
<<<<<<< HEAD
    let checkmarkAddButton = XCUIApplication().buttons["keyboard.saveButton"]
=======
    let checkmarkAddButton = XCUIApplication().buttons["keyboard.saveButton"] 
    let backspaceButton = XCUIApplication().staticTexts.matching(.staticText, identifier: "keyboard.backspaceButton")
    let clearButton = XCUIApplication().staticTexts.matching(.staticText, identifier: "keyboard.clearButton")
    let spacebarButton = XCUIApplication().staticTexts.matching(.staticText, identifier: "keyboard.spacebarButton")
    

    
>>>>>>> e112ebe (Adding Accessibility identifiers for the Keyboard view, in order to add some testing.)
    func typeText(_ textToType: String) {
        for char in textToType {
            if (String(char) == " "){
                spacebarButton.element(boundBy: 1).tap()
            }
            else {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
            }
        }
    }
    
    func randomString(length: Int) -> String {
<<<<<<< HEAD
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
=======
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ',.? "
      return String((0..<length).map{ _ in letters.randomElement()! })
>>>>>>> e112ebe (Adding Accessibility identifiers for the Keyboard view, in order to add some testing.)
    }
}
