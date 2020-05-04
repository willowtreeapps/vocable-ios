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
    let mySayingsSaveButton = XCUIApplication().buttons["keyboard.confirmButton"]
    let returnToMainScreenButton = XCUIApplication().buttons["keyboard.dismissButton"]
    
    func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
        }
    }
}
