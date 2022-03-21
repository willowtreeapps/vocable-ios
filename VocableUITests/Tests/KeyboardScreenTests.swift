//
//  KeyboardScreenTests.swift
//  KeyboardScreenTests
//
//  Created by Kevin Stechler on 4/22/20.
//  Updated by Rudy Salas and Canan Arikan on 03/17/2022
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class KeyboardScreenTests: BaseTest {
    
    func testKeyboardOutputIsDisplayed() {
        let testPhrase = "Test"
        
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
       
        XCTAssertTrue(keyboardScreen.keyboardTextView.staticTexts[testPhrase].exists, "Expected the text \(testPhrase) to be displayed")
    }
  
    func testAddPhraseToMySayingsFromKeyboard() {
        let testPhrase = "Test"
        
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.favoriteButton.tap()
        keyboardScreen.dismissKeyboardButton.tap()
        
        mainScreen.locateAndSelectDestinationCategory(.mySayings)

        XCTAssertTrue(mainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the phrase \(testPhrase) to be added to an displayed in 'My Sayings'")
    }
    
    func testRemovePhraseFromMySayingsFromKeyboard() {
       let testPhrase = "Test"
       
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.favoriteButton.tap()
        keyboardScreen.dismissKeyboardButton.tap()
       
        mainScreen.locateAndSelectDestinationCategory(.mySayings)
       
        XCTAssertTrue(mainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the phrase \(testPhrase) to be added to an displayed in 'My Sayings'")
        
        mainScreen.keyboardNavButton.tap()
        keyboardScreen.typeText(testPhrase)
        keyboardScreen.favoriteButton.tap()
        keyboardScreen.dismissKeyboardButton.tap()
        mainScreen.locateAndSelectDestinationCategory(.mySayings)
        
        XCTAssertFalse(mainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the phrase \(testPhrase) to be deleted from 'My Sayings'")
    }
     
}
