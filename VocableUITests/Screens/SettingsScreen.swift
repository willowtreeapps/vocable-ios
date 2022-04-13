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
    let mainScreen = MainScreen()
    let keyboardScreen = KeyboardScreen()
    
    let categoriesButton = XCUIApplication().collectionViews.staticTexts["Categories and Phrases"]
    let otherElements = XCUIApplication().collectionViews.cells.otherElements
    let cells = XCUIApplication().cells
    let settingsPageNextButton = XCUIApplication().buttons["bottomPagination.right_chevron"]
    let categoryUpButton = "reorder.upButton"
    let categoryDownButton = "reorder.downButton"
    let categoryForwardButton = "Forward"
    let hideCategorySwitch = "hide"
    let categoryShowButton = "show"
    let settingsPageAddCategoryButton = XCUIApplication().buttons["settingsCategory.addCategoryButton"]
    let alertContinueButton = XCUIApplication().buttons["alert.button.continue_editing"]
    let alertDiscardButton = XCUIApplication().buttons["alert.button.discard_changes"]
    let alertDeleteButton = XCUIApplication().buttons["alert.button.delete"]
    let alertRemoveButton = XCUIApplication().buttons["Remove"]
    let alertCancelButton = XCUIApplication().buttons["Cancel"]
    let categoryDetailsTitle = XCUIApplication().staticTexts["category_title_label"]
    let renameCategoryButton = XCUIApplication().buttons["rename_category_button"]
    let showCategoryButton = XCUIApplication().buttons["show_category_toggle"]
    let removeCategoryButton = XCUIApplication().buttons["remove_category_cell"]

    func openCategorySettings(category: String) {
        locateCategoryCell(category).staticTexts[category].tap()
    }
    
    func locateCategoryCell(_ category: String) -> XCUIElementQuery {
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
    
    private func categoryCellQuery(_ category: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        let cellLabel = cells.staticTexts.containing(predicate).element.label
        
        return XCUIApplication().cells.containing(.staticText, identifier: cellLabel)
    }
    
    func doesCategoryExist(_ category: String) -> Bool {
        var flag = false
        let predicate = NSPredicate(format: "label CONTAINS %@", category)
        
        // Loop through each custom category page to find our category
        for _ in 1...totalPageCount {
            if cells.staticTexts.containing(predicate).element.exists {
                flag = true
                break
            } else {
                mainScreen.paginationRightButton.tap()
            }
        }
        
        return flag
    }
    
    func toggleHideShowCategory(category: String, toggle: String) {
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
    
    func navigateToCategory(category: String) {
        while !otherElements.containing(.staticText, identifier: category).element.exists {
            settingsPageNextButton.tap()
            if mainScreen.pageNumber.label.contains("Page 1") {
                break
            }
        }
    }
    
    func addCategory(categoryName: String) {
        settingsPageAddCategoryButton.tap()
        let newCategory = keyboardScreen.randomString(length: 5)
        keyboardScreen.typeText(newCategory)
        keyboardScreen.checkmarkAddButton.tap()
    }
    
    func navigateToSettingsCategoryScreen() {
        _ = mainScreen.settingsButton.waitForExistence(timeout: 2)
        mainScreen.settingsButton.tap()
        _ = categoriesButton.waitForExistence(timeout: 2)
        categoriesButton.tap()
    }
    
    func returnToMainScreen() {
        navBarDismissButton.tap()
    }
    
}
