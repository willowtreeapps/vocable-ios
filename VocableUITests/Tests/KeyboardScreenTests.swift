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
        
        MainScreen.Accessibility.keyboardButton.element.tap()
        KeyboardScreen.typeText(testPhrase)
       
        XCTAssertTrue(KeyboardScreen.keyboardTextView.staticTexts[testPhrase].exists, "Expected the text \(testPhrase) to be displayed")
    }
  
    func testAddPhraseToMySayingsFromKeyboard() {
        let testPhrase = "Test"
        
        MainScreen.Accessibility.keyboardButton.element.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.favoriteButton.tap()
        KeyboardScreen.navBarDismissButton.tap()
        
        MainScreen.locateAndSelectDestinationCategory(.mySayings)

        XCTAssertTrue(MainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
    }
    
    func testRemovePhraseFromMySayingsFromKeyboard() {
       let testPhrase = "Test"
       
        MainScreen.Accessibility.keyboardButton.element.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.favoriteButton.tap()
        KeyboardScreen.navBarDismissButton.tap()
       
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
       
        XCTAssertTrue(MainScreen.locatePhraseCell(phrase: testPhrase).exists, "Expected the phrase \(testPhrase) to be added to and displayed in 'My Sayings'")
        
        MainScreen.Accessibility.keyboardButton.element.tap()
        KeyboardScreen.typeText(testPhrase)
        KeyboardScreen.favoriteButton.tap()
        KeyboardScreen.navBarDismissButton.tap()
        MainScreen.locateAndSelectDestinationCategory(.mySayings)
        
        // We expect 'My Sayings' to be empty now.
        XCTAssertTrue(MainScreen.emptyStateAddPhraseButton.exists, "Expected the phrase \(testPhrase) to be deleted from 'My Sayings'")
    }
     
}
