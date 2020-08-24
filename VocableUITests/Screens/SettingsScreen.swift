//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen {
    
    let categoriesButton = XCUIApplication().collectionViews.staticTexts["Categories and Phrases"]
    let leaveCategoryDetailButton = XCUIApplication().buttons["arrow.left"]
    let leaveCategoriesButton = XCUIApplication().buttons["arrow.left"]
    let exitSettings = XCUIApplication().buttons["xmark.circle"]
    let otherElements = XCUIApplication().collectionViews.cells.otherElements
    let settingsPageNextButton = "bottomPagination.right_chevron"
    let settingsPagePreviousButton = "bottomPagination.left_chevron"
    let settingsPageCategoryUpButton = "chevron.up"
    let settingsPageCategoryDownButton = "chevron.down"
    let settingsPageCategoryHideButton = "eye.slash.fill"
    let settingsPageCategoryShowButton = "eye.fill"
    
    
    func openCategorySettings(category: String) {
        if otherElements.containing(.staticText, identifier: category).element.exists {
            otherElements.containing(.staticText, identifier: category).buttons["Forward"].tap()
        } else {
            XCUIApplication().buttons[settingsPageNextButton].tap()
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
            XCUIApplication().buttons[settingsPageNextButton].tap()
           otherElements.containing(.staticText, identifier: category).buttons[toggleLabel].tap()
        }
    }
    
    
    func navigateToCategory(category: String){
        // If the settings is not on the first page go back to the beginning.
        if XCUIApplication().buttons[settingsPageNextButton].isEnabled{
            while
                XCUIApplication().buttons[settingsPageNextButton].isEnabled
                {
                    XCUIApplication().buttons[settingsPagePreviousButton].tap()
            }
        }
        if !otherElements.containing(.staticText, identifier: category).element.exists {
            while  !otherElements.containing(.staticText, identifier: category).element.exists {
                if XCUIApplication().buttons[settingsPageNextButton].isEnabled {
                XCUIApplication().buttons[settingsPageNextButton].tap()
                }
                else{
                    break
                }
            }
        }
    }
}
