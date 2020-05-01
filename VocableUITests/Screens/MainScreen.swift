//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen {
    let defaultCategories = ["General", "Basic Needs", "Personal Care", "Conversation", "Environment", "123", "My Sayings"]
    let defaultPhraseGeneral = ["Please be patient", "I don't know", "Maybe", "Yes", "I didn't mean to say that", "Please wait", "No", "Thank you"]
    let defaultPhraseBasicNeeds = ["I want to sit up", "I am finished", "I am uncomfortable", "I am fine", "I want to lie down", "I am in pain", "I am good", "I am tired"]
    
    static let keyboardNavButton = XCUIApplication().collectionViews.containing(.other, identifier: "Vertical scroll bar, 2 pages").children(matching: .cell).element(boundBy: 1).children(matching: .staticText).element
    static let categoryLeftButton = XCUIApplication().collectionViews.containing(.other, identifier: "Horizontal scroll bar, 1 page").children(matching: .cell).element(boundBy: 3).children(matching: .staticText).element
    static let categoryRightButton = XCUIApplication().collectionViews.containing(.other, identifier: "Horizontal scroll bar, 1 page").children(matching: .cell).element(boundBy: 5).children(matching: .staticText).element  
    
    func isTextDisplayed(_ text: String) -> Bool {
        return XCUIApplication().collectionViews.collectionViews.staticTexts[text].exists
    }
    
    func isTextDisplayedInTextView(_ text: String) -> Bool {
        return XCUIApplication().collectionViews.textViews.staticTexts[text].exists
    }
    
    func scrollRightAndTapCurrentCategory(numTimesToScroll: Int) {
        for _ in 1...numTimesToScroll {
            MainScreen.categoryRightButton.tap()
        }
        let currentCategory = numTimesToScroll % defaultCategories.count
        XCUIApplication().collectionViews.collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
    
    func scrollLeftAndTapCurrentCategory(numTimesToScroll: Int) {
        for _ in 1...numTimesToScroll {
            MainScreen.categoryLeftButton.tap()
        }
        let currentCategory = defaultCategories.count - (numTimesToScroll % defaultCategories.count)
        XCUIApplication().collectionViews.collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
}
