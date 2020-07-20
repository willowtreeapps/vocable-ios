//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen {
    
    let categoriesButton = XCUIApplication().collectionViews.staticTexts["Categories"]
    let showCategoryToggle = XCUIApplication().collectionViews.otherElements.containing(.staticText, identifier: "Show").element
    let leaveCategoryDetailButton = XCUIApplication().buttons["arrow.left"]
    let leaveCategoriesButton = XCUIApplication().buttons["arrow.left"]
    let exitSettings = XCUIApplication().buttons["xmark.circle"]
    
    func openCategorySettings(category: String) {
        if XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: category).element.exists {
            XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        } else {
            XCUIApplication().buttons["bottomPagination.right_chevron"].tap()
            XCUIApplication().collectionViews.cells.otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        }
        
    }
}
