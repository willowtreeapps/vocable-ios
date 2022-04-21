//
//  SettingsScreen.swift
//  VocableUITests
//
//  Created by Kevin Stechler on 5/19/20.
//  Updated by Canan Arikan and Rudy Salas on 03/28/22.
//  Copyright © 2022 WillowTree. All rights reserved.
//

import XCTest

class SettingsScreen: BaseScreen {
    
    private static let app = XCUIApplication()
    
    static let categoriesButton = app.collectionViews.staticTexts["Categories and Phrases"]
    static let timingAndSensitivityButton = app.collectionViews.staticTexts["Timing and Sensitivity"]
    static let otherElements = app.collectionViews.cells.otherElements
    static let cells = app.cells
    static let settingsPageNextButton = app.buttons["bottomPagination.right_chevron"]
    static let categoryUpButton = "reorder.upButton"
    static let categoryDownButton = "reorder.downButton"
    static let categoryForwardButton = "Forward"
    static let hideCategorySwitch = "hide"
    static let categoryShowButton = "show"
    static let settingsPageAddCategoryButton = app.buttons["settingsCategory.addCategoryButton"]
    static let alertContinueButton = app.buttons["alert.button.continue_editing"]
    static let alertDiscardButton = app.buttons["alert.button.discard_changes"]
    static let alertDeleteButton = app.buttons["alert.button.delete"]
    static let alertRemoveButton = app.buttons["Remove"]
    static let alertCancelButton = app.buttons["Cancel"]
    static let categoryDetailsTitle = app.staticTexts["category_title_label"]
    static let renameCategoryButton = app.buttons["rename_category_button"]
    static let showCategoryButton = app.buttons["show_category_toggle"]
    static let removeCategoryButton = app.buttons["remove_category_cell"]

    static func openCategorySettings(category: String) {
        locateCategoryCell(category).staticTexts[category].tap()
    }
    
    static func locateCategoryCell(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        // Loop through each page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists{
                break
            } else {
                settingsPageNextButton.tap()
            }
        }
        
        return categoryCellQuery(category)
    }
    
    private static func categoryCellQuery(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        let cellLabel = cells.staticTexts.containing(predicate).element.label
        
        return app.cells.containing(.staticText, identifier: cellLabel)
    }
    
    static func doesCategoryExist(_ category: String) -> Bool {
        var flag = false
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        
        // Loop through each custom category page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists {
                flag = true
                break
            } else {
                MainScreen.paginationRightButton.tap()
            }
        }
        
        return flag
    }
    
    static func toggleHideShowCategory(category: String, toggle: String) {
        var toggleLabel = ""
        switch toggle {
        case "Hide":
            toggleLabel = hideCategorySwitch
        case "Show":
            toggleLabel = categoryShowButton
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
    
    static func navigateToCategory(category: String) {
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            settingsPageNextButton.tap()
            if MainScreen.pageNumber.label.contains("Page 1") {
                break
            }
        }
    }
    
    static func addCategory(categoryName: String) {
        settingsPageAddCategoryButton.tap()
        let newCategory = KeyboardScreen.randomString(length: 5)
        KeyboardScreen.typeText(newCategory)
        KeyboardScreen.checkmarkAddButton.tap()
    }
    
    static func navigateToSettingsCategoryScreen() {
        MainScreen.settingsButton.tap(afterWaitingForExistenceWithTimeout: 2)
        categoriesButton.tap(afterWaitingForExistenceWithTimeout: 2)
    }
    
    static func returnToMainScreen() {
        navBarDismissButton.tap()
    }
    
    static func navigateToTimingAndSensitivityScreen() {
        MainScreen.settingsButton.tap(afterWaitingForExistenceWithTimeout: 2)
        SettingsScreen.timingAndSensitivityButton.tap(afterWaitingForExistenceWithTimeout: 2)
    }
}
