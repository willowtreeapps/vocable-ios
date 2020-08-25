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
    let checkmarkAddButton = XCUIApplication().buttons["checkmark"]
    let alertContinueButton = XCUIApplication().buttons["Continue Editing"]
    let alertDiscardButton = XCUIApplication().buttons["Discard"]
    
    func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
        }
    }
}
