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
    
// TODO: Uncomment when my sayins button added to keyboard modal
//    func testWhenAddingPhraseToMySayings_ThenItAppearsOnMainScreen() {
//        mainScreen.keyboardNavButton.tap()
//        keyboardScreen.typeText(testPhrase)
//        KeyboardScreen.mySayingsSaveButton.tap()
//        KeyboardScreen.returnToMainScreenButton.tap()
//        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 1)
//
//        XCTAssert(mainScreen.isTextDisplayed(testPhrase), "Expected the phrase \(testPhrase) to be added to an displayed in 'My Sayings'")
//    }
    
}
