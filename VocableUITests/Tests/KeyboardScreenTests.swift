//
//  KeyboardScreenTests.swift
//  KeyboardScreenTests
//
//  Created by Kevin Stechler on 4/22/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreenTests: BaseTest {
    let testPhrase = "Test"

    func testWhenTyping_ThenTextShownOnOutputLabel() {
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
       
        XCTAssert(keyboardScreen.keyboardTextView.staticTexts[testPhrase].exists, "Expected the text \(testPhrase) to be displayed")
    }
    /*
     // My sayings is being replaced with Custom Categories so this test will no longer apply.
    func testWhenAddingPhraseToMySayings_ThenItAppearsOnMainScreen() {
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.favoriteButton.tap()
        keyboardScreen.dismissKeyboardButton.tap()
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 1)

        XCTAssert(mainScreen.isTextDisplayed(testPhrase), "Expected the phrase \(testPhrase) to be added to an displayed in 'My Sayings'")
    }
    */
}
