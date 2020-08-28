//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen {
    let mainScreen = MainScreen()
    
    let categoriesButton = XCUIApplication().collectionViews.staticTexts["Categories and Phrases"]
    let leaveCategoryDetailButton = XCUIApplication().buttons["arrow.left"]
    let leaveCategoriesButton = XCUIApplication().buttons["arrow.left"]
    let exitSettings = XCUIApplication().buttons["settings.dismissButton"]
    let otherElements = XCUIApplication().collectionViews.cells.otherElements
    let settingsPageNextButton = XCUIApplication().buttons["bottomPagination.right_chevron"]
    let settingsPageCategoryUpButton = "chevron.up"
    let settingsPageCategoryDownButton = "chevron.down"
    let settingsPageCategoryHideButton = "eye.slash.fill"
    let settingsPageCategoryShowButton = "eye.fill"
    let settingsPageAddCategoryButton = XCUIApplication().buttons["settingsCategory.addCategoryButton"]
    
    
   
    func openCategorySettings(category: String) {
        if otherElements.containing(.staticText, identifier: category).element.exists {
            otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        } else {
            settingsPageNextButton.tap()
            otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        }
    }
    
    func toggleHideShowCategory(category: String, toggle: String) {
        var toggleLabel = ""
        switch toggle {
        case "Hide":
            toggleLabel = settingsPageCategoryHideButton
        case "Show":
            toggleLabel = settingsPageCategoryShowButton
        default:
            break
        }

        if otherElements.containing(.staticText, identifier: category).element.exists {
            otherElements.containing(.staticText, identifier: category).buttons[toggleLabel].tap()
        } else {
            settingsPageNextButton.tap()
           otherElements.containing(.staticText, identifier: category).buttons[toggleLabel].tap()
        }
    }
    
    
    func navigateToCategory(category: String){
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            settingsPageNextButton.tap()
            if (mainScreen.pageNumber.label == "Page 1 of 1"){
                break
            }
        }
    }
    
    func navigateToSettingsScreen() {
        mainScreen.settingsButton.tap()
        categoriesButton.tap()
    }
}
