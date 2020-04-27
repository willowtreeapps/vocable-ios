//
//  VocableUITests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/22/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class BaseTest: XCTestCase {
    let app = XCUIApplication()
    let keyboardScreen = KeyboardScreen()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() {
    }

    func testWhenOpeningScreen_ThenDefaultTextShown() {
        app.collectionViews.containing(.other, identifier: "Vertical scroll bar, 2 pages")
            .children(matching: .cell)
            .element(boundBy: 1).children(matching: .staticText).element.tap()
        XCUIApplication().collectionViews/*@START_MENU_TOKEN@*/.staticTexts["A"]/*[[".cells.staticTexts[\"A\"]",".staticTexts[\"A\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        keyboardScreen.typeText("test")
    }
    
}
