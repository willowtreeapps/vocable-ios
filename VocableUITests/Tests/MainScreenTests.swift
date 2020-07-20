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
        for categoryName in mainScreen.defaultCategories {
            XCTAssert(mainScreen.isTextDisplayed(categoryName), "Expected the current category name to be \(categoryName)")
            mainScreen.categoryRightButton.tap()
        }
    }
    
    func testDefaultSayingsInGeneralCategoryExist() {
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseGeneral)
    }
    
    func testSelectingCategoryChangesPhrases() {
        mainScreen.scrollRightAndTapCurrentCategory(numTimesToScroll: 1)
        verifyGivenPhrasesDisplay(setOfPhrases: mainScreen.defaultPhraseBasicNeeds)
    }
    
    func testWhenTappingPhrase_ThenThatPhraseDisplaysOnOutputLabel() {
        XCUIApplication().collectionViews.staticTexts[mainScreen.defaultPhraseGeneral[0]].tap()
        XCTAssertEqual(mainScreen.outputLabel.label, mainScreen.defaultPhraseGeneral[0])
    }
    
    func testWhenTapping123Phrase_ThenThatPhraseDisplaysOnOutputLabel() {
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 2)
        XCUIApplication().collectionViews.staticTexts[mainScreen.defaultPhrase123[0]].tap()
        XCTAssertEqual(mainScreen.outputLabel.label, mainScreen.defaultPhrase123[0])
    }
    
    func testDisablingCategory() {
        let generalCategoryText = "1. General"
        let hiddenGeneralCategoryText = " General"
        
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.openCategorySettings(category: generalCategoryText)
        settingsScreen.showCategoryToggle.tap()

        settingsScreen.leaveCategoryDetailButton.tap()
        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettings.tap()
        
        XCTAssertFalse(XCUIApplication().collectionViews.staticTexts[mainScreen.defaultCategories[0]].exists)
        
        //since settings changes persist through app restarts, we have to reset the categories back to default after our test.
        //once the reset settings functionality is implemented, or better yet, a reset settings environment variable, this can be deleted
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.openCategorySettings(category: hiddenGeneralCategoryText)
        settingsScreen.showCategoryToggle.tap()
    }
    
    private func verifyGivenPhrasesDisplay(setOfPhrases: [String]) {
        for phrase in setOfPhrases {
            XCTAssert(mainScreen.isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
}
