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
        let hiddenGeneralCategoryText = "General"
        
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.toggleHideShowCategory(category: generalCategoryText, toggle: "Hide")

        settingsScreen.leaveCategoriesButton.tap()
        settingsScreen.exitSettings.tap()
        
        XCTAssertFalse(XCUIApplication().collectionViews.staticTexts[mainScreen.defaultCategories[0]].exists)
        
        //since settings changes persist through app restarts, we have to reset the categories back to default after our test.
        //once the reset settings functionality is implemented, or better yet, a reset settings environment variable, this can be deleted
        mainScreen.settingsButton.tap()
        settingsScreen.categoriesButton.tap()
        
        settingsScreen.toggleHideShowCategory(category: hiddenGeneralCategoryText, toggle: "Show")
    }
    
    func testMySettingsPagination() {
        mainScreen.scrollLeftAndTapCurrentCategory(numTimesToScroll: 1)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        XCTAssertFalse(mainScreen.paginationLeftButton.isEnabled)
        XCTAssertFalse(mainScreen.paginationRightButton.isEnabled)
        addMySayings(numberOfSayings: 8)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 1")
        addMySayings(numberOfSayings: 1)
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 1 of 2")
        XCTAssertTrue(mainScreen.paginationRightButton.isEnabled)
        
        mainScreen.paginationRightButton.tap()
        XCTAssertEqual(mainScreen.pageNumber.label, "Page 2 of 2")
        
    }

    
    private func verifyGivenPhrasesDisplay(setOfPhrases: [String]) {
        for phrase in setOfPhrases {
            XCTAssert(mainScreen.isTextDisplayed(phrase), "Expected the phrase \(phrase) to be displayed")
        }
    }
    
    private func addMySayings(numberOfSayings: Int){
         for _ in 1...numberOfSayings {
            let randomPhrase = keyboardScreen.randomString(length: 5)
          
            mainScreen.keyboardNavButton.tap()
            keyboardScreen.typeText(randomPhrase)
            keyboardScreen.favoriteButton.tap()
          
            // Do this until accessibility identifiers are add and trash icon can be accessed.
            keyboardScreen.dismissKeyboardButton.tap()
          }
      }
}
