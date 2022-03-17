//
//  MainScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 4/27/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class MainScreen: BaseScreen {
    private let app = XCUIApplication()
    
    var defaultCategories = ["General", "Basic Needs", "Personal Care", "Conversation", "Environment", "123", "My Sayings", "Recents", "Listen"]
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
       
    func scrollRightAndTapCurrentCategory(numTimesToScroll: Int, startingCategory: String) {
        
        for _ in 1...numTimesToScroll {
            categoryRightButton.tap()
        }
        
        let currentPosition = defaultCategories.firstIndex(of: startingCategory)!
        let categoryToClick = (currentPosition+numTimesToScroll) % defaultCategories.count
        app.collectionViews.staticTexts[defaultCategories[categoryToClick]].tap()
    }
    
    func scrollLeftAndTapCurrentCategory(numTimesToScroll: Int, newCategory: String?) {
        for _ in 1...numTimesToScroll {
            categoryLeftButton.tap()
        }
        defaultCategories.append(newCategory ?? " ")
        if newCategory == nil {
            _ = defaultCategories.popLast()
        }
        let currentCategory = defaultCategories.count - (numTimesToScroll % defaultCategories.count)
        app.collectionViews.staticTexts[defaultCategories[currentCategory]].tap()
    }
    
    func scrollToMySayings() {
        let mySayingsIdentifier = "category_title_cell_preset_user_favorites"
        scrollRightFindCategoryAndTap(identifier: mySayingsIdentifier)
    }
    
    private func scrollRightFindCategoryAndTap(identifier: String){
       
        // Loop through each category to find our category
        let maxNumOfClickToReachCategory = 15
        for _ in 1...maxNumOfClickToReachCategory {
            if app.cells[identifier].exists {
                app.cells[identifier].tap()
                paginationRightButton.waitForExistence(timeout: 1)
                break
            } else {
                categoryRightButton.tap()
            }
        }
    }
    
    func findPhrase(phrase: String) {
        
        let predicate = NSPredicate(format: "label CONTAINS %@", phrase)
        
        // Loop through each custom category page to find our phrase
        for _ in 1...totalPageCount {
            if app.cells.staticTexts.containing(predicate).element.exists {
                break
            } else {
                paginationRightButton.tap()
            }
        }
    }
    
}
