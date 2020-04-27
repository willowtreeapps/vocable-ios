//
//  MainScreenTests.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreenTests: TestHelper {
    
    func testDefaultCategoriesExist() {
        for categoryName in MainScreen().defaultCategories {
            XCTAssert(MainScreen().isTextDisplayed(categoryName), "Expected the current category name to be \(categoryName)")
            MainScreen.categoryRightButton.tap()
        }
    }
    
    func testDefaultSayingsInGeneralCategoryExist() {
        for phrase in MainScreen().defaultPhraseGeneral {
            XCTAssert(MainScreen().isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
    
    func testSelectingCategoryChangesPhrases() {
        MainScreen.categoryRightButton.tap()
        XCUIApplication().collectionViews.collectionViews.staticTexts[MainScreen().defaultCategories[1]].tap()
        for phrase in MainScreen().defaultPhraseBasicNeeds {
            XCTAssert(MainScreen().isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
}
