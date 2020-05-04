//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: BaseTest {

    func testDefaultCategoriesExist() {
        for categoryName in MainScreen.defaultCategories {
            XCTAssert(MainScreen.isTextDisplayed(categoryName), "Expected the current category name to be \(categoryName)")
            MainScreen.categoryRightButton.tap()
        }
    }
    
    func testDefaultSayingsInGeneralCategoryExist() {
        verifyGivenPhrasesDisplay(setOfPhrases: MainScreen.defaultPhraseGeneral)
    }
    
    func testSelectingCategoryChangesPhrases() {
        MainScreen.scrollRightAndTapCurrentCategory(numTimesToScroll: 1)
        verifyGivenPhrasesDisplay(setOfPhrases: MainScreen.defaultPhraseBasicNeeds)
    }
    
    func testWhenTappingPhrase_ThenTextFieldPopulates() {
        XCUIApplication().collectionViews.staticTexts[MainScreen.defaultPhraseGeneral[0]].tap()
//        XCTAssert(MainScreen.isTextDisplayedInTextView("Please be patient"))
    }
    
    private func verifyGivenPhrasesDisplay(setOfPhrases: [String]) {
        for phrase in setOfPhrases {
            XCTAssert(MainScreen.isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
}
