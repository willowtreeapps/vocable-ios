//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: BaseTest {
    let mainScreen = MainScreen()
    
    func testDefaultCategoriesExist() {
        for categoryName in MainScreen().defaultCategories {
            XCTAssert(mainScreen.isTextDisplayed(categoryName), "Expected the current category name to be \(categoryName)")
            MainScreen.categoryRightButton.tap()
        }
    }
    
    func testDefaultSayingsInGeneralCategoryExist() {
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseGeneral)
    }
    
    func testSelectingCategoryChangesPhrases() {
        mainScreen.scrollRightAndTapCurrentCategory(numTimesToScroll: 1)
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseBasicNeeds)
    }
    
    func testWhenTappingPhrase_ThenTextFieldPopulates() {
        XCUIApplication().collectionViews.collectionViews.staticTexts[mainScreen.defaultPhraseGeneral[0]].tap()
        XCTAssert(mainScreen.isTextDisplayedInTextView("Please be patient"))
    }
    
    private func verifyGivenPhrasesDisplay(setOfPhrases: [String]) {
        for phrase in setOfPhrases {
            XCTAssert(mainScreen.isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
}
