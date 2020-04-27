//
//  KeyboardScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/24/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreen: XCTestCase {
    let app = XCUIApplication()
    
    func typeText(_ textToType: String) {
        for char in textToType {
            app.collectionViews.staticTexts[String(char)].tap()
        }
    }
}
