//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen {
    static let defaultCategories = ["General", "Basic Needs", "Personal Care", "Conversation", "Environment", "123", "My Sayings"]
    static let defaultPhraseGeneral = ["Please be patient", "I don't know", "Maybe", "Yes", "I didn't mean to say that", "Please wait", "No", "Thank you"]
    static let defaultPhraseBasicNeeds = ["I want to sit up", "I am finished", "I am uncomfortable", "I am fine", "I want to lie down", "I am in pain", "I am good", "I am tired"]

    static var settingsButton: XCUIElement {
        XCUIApplication().buttons.matching(identifier: "root.settingsButton").element
    }

    static var outputLabel: XCUIElement {
        XCUIApplication().staticTexts.matching(identifier: "root.outputTextLabel").element
    }

    static var keyboardNavButton: XCUIElement {
        XCUIApplication().buttons.matching(identifier: "root.keyboardButton").element
    }

    static var categoryLeftButton: XCUIElement {
        XCUIApplication().buttons.matching(identifier: "root.categories_carousel.left_chevron").element
    }

    static var categoryRightButton: XCUIElement {
        XCUIApplication().buttons.matching(identifier: "root.categories_carousel.right_chevron").element
    }

    static func isTextDisplayed(_ text: String) -> Bool {
        return XCUIApplication().collectionViews.staticTexts[text].exists
    }
    
    static func scrollRightAndTapCurrentCategory(numTimesToScroll: Int) {
        for _ in 1...numTimesToScroll {
            categoryRightButton.tap()
        }
        let currentCategory = numTimesToScroll % defaultCategories.count
        XCUIApplication().collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
    
    static func scrollLeftAndTapCurrentCategory(numTimesToScroll: Int) {
        for _ in 1...numTimesToScroll {
            categoryLeftButton.tap()
        }
        let currentCategory = defaultCategories.count - (numTimesToScroll % defaultCategories.count)
        XCUIApplication().collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
}
