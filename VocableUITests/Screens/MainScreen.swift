//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen {
    private let app = XCUIApplication()
   
    
    var defaultCategories = ["General", "Basic Needs", "Personal Care", "Conversation", "Environment", "123", "My Sayings"]
    let defaultPhraseGeneral = ["Please be patient", "I don't know", "Maybe", "Yes", "I didn't mean to say that", "Please wait", "No", "Thank you"]
    let defaultPhrase123 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "No", "Yes"]
    let defaultPhraseBasicNeeds = ["I want to sit up", "I am finished", "I am uncomfortable", "I am fine", "I want to lie down", "I am in pain", "I am good", "I am tired"]

    let settingsButton = XCUIApplication().buttons["root.settingsButton"]
    let outputLabel = XCUIApplication().staticTexts["root.outputTextLabel"]
    let keyboardNavButton = XCUIApplication().buttons["root.keyboardButton"]
    let categoryLeftButton = XCUIApplication().buttons["root.categories_carousel.left_chevron"]
    let categoryRightButton = XCUIApplication().buttons["root.categories_carousel.right_chevron"]
    let pageNumber = XCUIApplication().staticTexts["bottomPagination.pageNumber"]
    let paginationLeftButton = XCUIApplication().buttons["bottomPagination.left_chevron"]
    let paginationRightButton = XCUIApplication().buttons["bottomPagination.right_chevron"]
    
    
    func isTextDisplayed(_ text: String) -> Bool {
        return app.collectionViews.staticTexts[text].exists
    }
    
    func scrollRightAndTapCurrentCategory(numTimesToScroll: Int) {
        for _ in 1...numTimesToScroll {
            categoryRightButton.tap()
        }
        let currentCategory = numTimesToScroll % defaultCategories.count
        app.collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
    
    func scrollLeftAndTapCurrentCategory(numTimesToScroll: Int, newCategory: String?) {
        for _ in 1...numTimesToScroll {
            categoryLeftButton.tap()
        }
        defaultCategories.append(newCategory ?? " ")
        if (newCategory == nil) {
            defaultCategories.popLast()
        }
        let currentCategory = defaultCategories.count - (numTimesToScroll % defaultCategories.count)
        app.collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
}
