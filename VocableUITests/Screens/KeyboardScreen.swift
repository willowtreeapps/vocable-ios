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
    lazy var keyboardTextView = app.textViews.matching(identifier: "keyboard.textView").element
    lazy var mySayingsSaveButton = app.buttons.matching(identifier: "keyboard.confirmButton").element
    lazy var returnToMainScreenButton = app.buttons.matching(identifier: "keyboard.dismissButton").element
    
    func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
        }
    }
}
