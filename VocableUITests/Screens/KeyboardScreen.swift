//
//  KeyboardScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreen {
    let app = XCUIApplication()
    static let keyboardTextView = XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element(boundBy: 1)
    static let mySayingsSaveButton = XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 1).children(matching: .staticText).element
    static let returnToMainScreenButton = XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 2).children(matching: .staticText).element
    
    func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char).uppercased()].tap()
        }
    }
}
