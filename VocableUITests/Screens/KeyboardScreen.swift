//
//  KeyboardScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreen: BaseScreen {
    private static let app = XCUIApplication()
    
    static let keyboardTextView = XCUIApplication().textViews[.shared.keyboard.outputTextView]
    static let favoriteButton = XCUIApplication().buttons[.shared.keyboard.favoriteButton]
    static let checkmarkAddButton = XCUIApplication().buttons[.shared.keyboard.saveButton]
    static let createDuplicateButton = XCUIApplication().buttons["Create Duplicate"]
    
    static func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
        }
    }
    
    static func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
